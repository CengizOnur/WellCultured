//
//  ImageClient.swift
//  We ll Cultured
//
//  Created by Onur Akdogan on 2.07.2022.
//

import UIKit

protocol ImageService {
    
    func downloadImage(fromURL url: URL, completion: @escaping (Result<UIImage, WellCulturedError>) -> Void) -> URLSessionTaskProtocol?
    
    func setImage(on imageView: UIImageView, fromURL url: URL, withPlaceholder placeholder: UIImage?)
}


final class ImageClient: ImageService {
    
    // MARK: - Static Properties
    
    /// There is no need to wrap the modification with an asynchronous dispatch call to the main thread. It is already handled in helper function in ImageClient.
    static let shared = ImageClient(session: URLSession.shared, responseQueue: .main)
    
    // MARK: - Instance Properties
    
    let cachedImageForURL = NSCache<NSURL, UIImage>()
    var cachedTaskForImageView: [UIImageView: URLSessionTaskProtocol]
    let session: URLSessionProtocol
    let responseQueue: DispatchQueue?
    
    
    // MARK: - Object Lifecycle
    
    /// There is no need to wrap the modification with an asynchronous dispatch call to the main thread as long as setting responseQueue parameter to .main. Otherwise, modification must be wrapped with an asynchronous dispatch call to the main thread for sure.
    init(session: URLSessionProtocol, responseQueue: DispatchQueue?) {
        self.cachedTaskForImageView = [:]
        self.session = session
        self.responseQueue = responseQueue
    }
    
    
    func downloadImage(fromURL url: URL, completion: @escaping (Result<UIImage, WellCulturedError>) -> Void) -> URLSessionTaskProtocol? {
        guard url.absoluteString != "unavailableImage" else {
            dispatchResult(error: .unavailableImage, completion: completion)
            return nil
        }
        
        if let cachedImage = cachedImageForURL.object(forKey: url as NSURL) {
            dispatchResult(image: cachedImage, completion: completion)
            return nil
        }
        
        let task = session.makeDataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let _ = error {
                self.dispatchResult(error: .unableToComplete, completion: completion)
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.dispatchResult(error: .invalidResponse, completion: completion)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                self.cachedImageForURL.setObject(image, forKey: url as NSURL)
                self.dispatchResult(image: image, completion: completion)
            }  else {
                self.dispatchResult(error: .invalidData, completion: completion)
            }
        }
        task.resume()
        
        return task
    }
    
    
    func setImage(on imageView: UIImageView, fromURL url: URL, withPlaceholder placeholder: UIImage?) {
        cachedTaskForImageView[imageView]?.cancel()
        imageView.image = placeholder
        imageView.tintColor = .systemGray4
        imageView.dismissImageLoadingView()
        imageView.showImageLoadingView()
        
        // As long as ImageClient.shared is used, there is no need to wrap the modification with an asynchronous dispatch call to the main thread. It is already handled in helper function in ImageClient by setting parameter responseQueue to .main within ImageClient.shared.
        cachedTaskForImageView[imageView] = downloadImage(fromURL: url) { [weak self] result in
            guard let self = self else { return }
            self.cachedTaskForImageView[imageView] = nil
            imageView.dismissImageLoadingView()
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            
            switch result {
            case .success(let image):
                imageView.image = image
            case .failure(let error):
                if error == .unavailableImage {
                    imageView.image = UIImage(named: "unavailableImage")
                }
            }
        }
    }
    
    
    private func dispatchResult(image: UIImage? = nil, error: WellCulturedError? = nil, completion: @escaping (Result<UIImage, WellCulturedError>) -> Void) {
        if let responseQueue = responseQueue {
            responseQueue.async { [weak self] in
                self?.completeCases(image: image, error: error, completion: completion)
            }
        } else {
            completeCases(image: image, error: error, completion: completion)
        }
    }
    
    
    func completeCases(image: UIImage? = nil, error: WellCulturedError? = nil, completion: @escaping (Result<UIImage, WellCulturedError>) -> Void) {
        if let image = image {
            completion(.success(image))
        } else if let error = error {
            completion(.failure(error))
        }
    }
}
