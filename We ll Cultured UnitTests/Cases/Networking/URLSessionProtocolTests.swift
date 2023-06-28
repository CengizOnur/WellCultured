//
//  URLSessionProtocolTests.swift
//  We ll Cultured UnitTests
//
//  Created by Onur Akdogan on 28.06.2022.
//

@testable import We_ll_Cultured
import XCTest

final class URLSessionProtocolTests: XCTestCase {
    
    var session: URLSession!
    var url: URL!
    
    override func setUp() {
        super.setUp()
        session = URLSession(configuration: .default)
        url = URL(string: "https://example.com")!
    }
    
    override func tearDown() {
        session = nil
        url = nil
        super.tearDown()
    }
    
    
    func test_URLSessionTask_conformsToURLSessionTaskProtocol() {
        // when
        let task = session.dataTask(with: url)
        
        // then
        XCTAssertTrue((task as AnyObject) is URLSessionTaskProtocol)
    }
    
    
    func test_URLSession_conformsToURLSessionProtocol() {
        XCTAssertTrue((session as AnyObject) is URLSessionProtocol)
    }
    
    
    func test_URLSession_makeDataTaskCreatesTaskWithPassedInURL() {
        // when
        let task = session.makeDataTask(with: url, completionHandler: { _, _, _ in }) as! URLSessionTask
        
        // then
        XCTAssertEqual(task.originalRequest?.url, url)
    }
    
    
    func test_URLSession_makeDataTask_createsTaskWithPassedInCompletion() {
        // given
        let expectation = expectation(description: "Completion should be called")
        
        // when
        let task = session.makeDataTask(with: url, completionHandler: { _, _, _ in
            expectation.fulfill()
        }) as! URLSessionTask
        task.cancel()
        
        // then
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}
