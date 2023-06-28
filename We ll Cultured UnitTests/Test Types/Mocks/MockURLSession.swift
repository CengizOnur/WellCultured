//
//  MockURLSession.swift
//  We ll Cultured UnitTests
//
//  Created by Onur Akdogan on 29.06.2022.
//

@testable import We_ll_Cultured
import Foundation

final class MockURLSession: URLSessionProtocol {
    
    var queue: DispatchQueue? = nil
    
    func givenDispatchQueue() {
        queue = DispatchQueue(label: "com.WellCulturedTests.MockSession")
    }
    
    func makeDataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        return MockURLSessionTask(completionHandler: completionHandler, url: url, queue: queue)
    }
}


final class MockURLSessionTask: URLSessionTaskProtocol {
    
    var completionHandler: (Data?, URLResponse?, Error?) -> Void
    var url: URL
    
    init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void, url: URL, queue: DispatchQueue?) {
        if let queue = queue {
            self.completionHandler = { data, response, error in
                queue.async() {
                    completionHandler(data, response, error)
                }
            }
        } else {
            self.completionHandler = completionHandler
        }
        self.url = url
    }
    
    var calledCancel = false
    func cancel() { calledCancel = true }
    
    var calledResume = false
    func resume() { calledResume = true }
}
