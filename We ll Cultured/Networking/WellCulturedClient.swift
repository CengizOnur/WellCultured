//
//  WellCulturedClient.swift
//  We ll Cultured
//
//  Created by Onur Akdogan on 28.06.2022.
//

import Foundation

protocol WellCulturedService {
    
    func getExhibit(about: String, completion: @escaping (Result<ExhibitData, WellCulturedError>) -> Void) -> URLSessionTaskProtocol
    
    func getArtifact(with objectID: Int, completion: @escaping (Result<ArtifactData, WellCulturedError>) -> Void) -> URLSessionTaskProtocol
}


final class WellCulturedClient: WellCulturedService {
    
    // MARK: - Static Properties
    
    /// There is no need to wrap the modification with an asynchronous dispatch call to the main thread. It is already handled in helper function in WellCulturedClient.
    static let shared = WellCulturedClient(
        baseURL: URL(string:"https://collectionapi.metmuseum.org/public/collection/v1/")!,
        session: URLSession.shared,
        responseQueue: .main)
    
    // MARK: - Instance Properties
    let baseURL: URL
    let session: URLSessionProtocol
    let responseQueue: DispatchQueue?
    
    /// There is no need to wrap the modification with an asynchronous dispatch call to the main thread as long as setting responseQueue parameter to .main. Otherwise, modification must be wrapped with an asynchronous dispatch call to the main thread for sure.
    init(baseURL: URL, session: URLSessionProtocol, responseQueue: DispatchQueue?) {
        self.baseURL = baseURL
        self.session = session
        self.responseQueue = responseQueue
    }
    
    
    func getExhibit(about: String, completion: @escaping (Result<ExhibitData, WellCulturedError>) -> Void) -> URLSessionTaskProtocol {
        let url = URL(string: "search?title=true&isOnView=true&hasImage=true&q=\(about)", relativeTo: baseURL) ?? URL(string: "search?title=true&isOnView=true&hasImage=true&q=")!
        
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
            
            guard let data = data else {
                self.dispatchResult(error: .invalidData, completion: completion)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let exhibits = try decoder.decode(ExhibitData.self, from: data)
                self.dispatchResult(models: exhibits, completion: completion)
            } catch {
                self.dispatchResult(error: .invalidParse, completion: completion)
            }
        }
        task.resume()
        
        return task
    }
    
    
    func getArtifact(with objectID: Int, completion: @escaping (Result<ArtifactData, WellCulturedError>) -> Void) -> URLSessionTaskProtocol {
        let url = URL(string: "objects/\(objectID)", relativeTo: baseURL)!
        
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
            
            guard let data = data else {
                self.dispatchResult(error: .invalidData, completion: completion)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let exhibits = try decoder.decode(ArtifactData.self, from: data)
                self.dispatchResult(models: exhibits, completion: completion)
            } catch {
                self.dispatchResult(error: .invalidParse, completion: completion)
            }
        }
        task.resume()
        
        return task
    }
    
    
    func dispatchResult<T>(models: T? = nil, error: WellCulturedError? = nil, completion: @escaping (Result<T, WellCulturedError>) -> Void) {
        if let responseQueue = responseQueue {
            responseQueue.async { [weak self] in
                self?.completeCases(models: models, error: error, completion: completion)
            }
        } else {
            completeCases(models: models, error: error, completion: completion)
        }
    }
    
    
    func completeCases<T>(models: T? = nil, error: WellCulturedError? = nil, completion: @escaping (Result<T, WellCulturedError>) -> Void) {
        if let models = models {
            completion(.success(models))
        } else if let error = error {
            completion(.failure(error))
        }
    }
}
