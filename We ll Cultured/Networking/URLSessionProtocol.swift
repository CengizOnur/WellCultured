//
//  URLSessionProtocol.swift
//  We ll Cultured
//
//  Created by Onur Akdogan on 28.06.2022.
//

import Foundation

protocol URLSessionProtocol: AnyObject {
    func makeDataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol
}


extension URLSession: URLSessionProtocol {
    func makeDataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        return dataTask(with: url, completionHandler: completionHandler)
    }
}


protocol URLSessionTaskProtocol: AnyObject {
    func cancel()
    func resume()
}


extension URLSessionTask: URLSessionTaskProtocol { }
