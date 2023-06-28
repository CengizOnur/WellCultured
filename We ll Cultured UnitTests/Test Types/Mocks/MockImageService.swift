//
//  MockImageService.swift
//  We ll Cultured UnitTests
//
//  Created by Onur Akdogan on 3.07.2022.
//

@testable import We_ll_Cultured
import UIKit

final class MockImageService: ImageService {
    
    var setImageCallCount = 0
    var receivedImageView: UIImageView!
    var receivedURL: URL!
    var receivedPlaceholder: UIImage!
    
    
    func downloadImage(fromURL url: URL, completion: @escaping (Result<UIImage, WellCulturedError>) -> Void) -> URLSessionTaskProtocol? {
        return nil
    }
    
    
    func setImage(on imageView: UIImageView, fromURL url: URL, withPlaceholder placeholder: UIImage?) {
        setImageCallCount += 1
        receivedImageView = imageView
        receivedURL = url
        receivedPlaceholder = placeholder
    }
}
