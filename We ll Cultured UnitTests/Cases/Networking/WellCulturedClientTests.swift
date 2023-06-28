//
//  WellCulturedClientTests.swift
//  We ll Cultured UnitTests
//
//  Created by Onur Akdogan on 28.06.2022.
//

@testable import We_ll_Cultured
import XCTest

final class WellCulturedClientTests: XCTestCase {
    
    var sut: WellCulturedClient!
    var mockSession: MockURLSession!
    var service: WellCulturedService {
        return sut as WellCulturedService
    }
    
    var getExhibitURL: URL { return URL(string: "search?title=true&isOnView=true&hasImage=true&q=\(query!)", relativeTo: baseURL)! }
    var getArtifactURL: URL { return URL(string: "objects/\(objectID!)", relativeTo: baseURL)! }
    
    var baseURL: URL!
    var query: String!
    var objectID: Int!
    
    override func setUp() {
        super.setUp()
        query = "flower"
        objectID = 11207
        baseURL = URL(string: "https://example.com/api/v1/")!
        mockSession = MockURLSession()
        sut = WellCulturedClient(baseURL: baseURL, session: mockSession, responseQueue: nil)
    }
    
    override func tearDown() {
        baseURL = nil
        mockSession = nil
        query = nil
        objectID = nil
        sut = nil
        super.tearDown()
    }
    
    
    // MARK: - When
    
    func whenGetExhibit(data: Data? = nil, statusCode: Int = 200, error: Error? = nil) -> (calledCompletion: Bool, exhibit: ExhibitData?, error: WellCulturedError?) {
        var calledCompletion = false
        var receivedExhibit: ExhibitData? = nil
        var receivedError: WellCulturedError? = nil
        
        let mockTask = sut.getExhibit(about: query) { result in
            calledCompletion = true
            switch result {
            case .success(let exhibit):
                receivedExhibit = exhibit
            case .failure(let error):
                receivedError = error as WellCulturedError?
            }
        } as! MockURLSessionTask
        
        let response = HTTPURLResponse(url: getExhibitURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        mockTask.completionHandler(data, response, error)
        
        return (calledCompletion, receivedExhibit, receivedError)
    }
    
    
    func whenGetArtifact(data: Data? = nil, statusCode: Int = 200, error: Error? = nil) -> (calledCompletion: Bool, artifact: ArtifactData?, error: WellCulturedError?) {
        var calledCompletion = false
        var receivedArtifact: ArtifactData? = nil
        var receivedError: WellCulturedError? = nil
        
        let mockTask = sut.getArtifact(with: objectID) { result in
            calledCompletion = true
            switch result {
            case .success(let artifact):
                receivedArtifact = artifact
            case .failure(let error):
                receivedError = error as WellCulturedError?
            }
        } as! MockURLSessionTask
        
        let response = HTTPURLResponse(url: getArtifactURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        mockTask.completionHandler(data, response, error)
        
        return (calledCompletion, receivedArtifact, receivedError)
    }
    
    
    // MARK: - Then
    
    func verifyGetExhibitDispatchedToMain(data: Data? = nil, statusCode: Int = 200, error: Error? = nil, line: UInt = #line) {
        mockSession.givenDispatchQueue()
        
        sut = WellCulturedClient(baseURL: baseURL, session: mockSession, responseQueue: .main)
        var thread: Thread!
        let expectation = self.expectation(description: "Completion wasn't called")
        
        // when
        let mockTask = sut.getExhibit(about: query) { _ in
            thread = Thread.current
            expectation.fulfill()
        } as! MockURLSessionTask
        
        let response = HTTPURLResponse(url: getExhibitURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        mockTask.completionHandler(data, response, error)
        
        // then
        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertTrue(thread.isMainThread, line: line)
        }
    }
    
    
    func verifyGetArtifactDispatchedToMain(data: Data? = nil, statusCode: Int = 200, error: Error? = nil, line: UInt = #line) {
        mockSession.givenDispatchQueue()
        
        sut = WellCulturedClient(baseURL: baseURL, session: mockSession, responseQueue: .main)
        var thread: Thread!
        let expectation = self.expectation(description: "Completion wasn't called")
        
        // when
        let mockTask = sut.getArtifact(with: objectID) { _ in
            thread = Thread.current
            expectation.fulfill()
        } as! MockURLSessionTask
        
        let response = HTTPURLResponse(url: getArtifactURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        mockTask.completionHandler(data, response, error)
        
        // then
        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertTrue(thread.isMainThread, line: line)
        }
    }
    
    
    // MARK: - WellCulturedService - Tests
    
    func test_conformsTo_WellCulturedService() {
        XCTAssertTrue((sut as AnyObject) is WellCulturedService)
    }
    
    
    func test_wellCulturedService_declaresGetExhibit() {
        _ = service.getExhibit(about: query) { (_) in }
    }
    
    
    func test_wellCulturedService_declaresGetArtifact() {
        _ = service.getArtifact(with: objectID) { (_) in }
    }
    
    
    // MARK: - Static Properties - Tests
    
    func test_shared_setsBaseURL() {
        // given
        let baseURL = URL(string: "https://collectionapi.metmuseum.org/public/collection/v1/")!
        
        // then
        XCTAssertEqual(WellCulturedClient.shared.baseURL, baseURL)
    }
    
    
    func test_shared_setsSession() {
        XCTAssertTrue(WellCulturedClient.shared.session === URLSession.shared)
    }
    
    
    func test_shared_setsResponseQueue() {
        XCTAssertEqual(WellCulturedClient.shared.responseQueue, .main)
    }
    
    
    // MARK: - Object Lifecycle - Tests
    
    func test_init_setsBaseURL() {
        XCTAssertEqual(sut.baseURL ,baseURL)
    }
    
    
    func test_init_setsSession() {
        XCTAssertTrue(sut.session === mockSession)
    }
    
    
    func test_init_sets_responseQueue() {
        XCTAssertTrue(sut.responseQueue === nil)
    }
    
    
    // MARK: - Functionality - Tests
    
    func test_getExhibit_createsExpectedTask() {
        // when
        let mockTask = sut.getExhibit(about: query) { _ in } as! MockURLSessionTask
        
        // then
        XCTAssertEqual(mockTask.url, getExhibitURL)
    }
    
    
    func test_getArtifact_createsExpectedTask() {
        // when
        let mockTask = sut.getArtifact(with: objectID) { _ in } as! MockURLSessionTask
        
        // then
        XCTAssertEqual(mockTask.url, getArtifactURL)
    }
    
    
    func test_getExhibit_callsResumeOnTask() {
        // when
        let mockTask = sut.getExhibit(about: query) { _ in } as! MockURLSessionTask
        
        // then
        XCTAssertTrue(mockTask.calledResume)
    }
    
    
    func test_getArtifact_callsResumeOnTask() {
        // when
        let mockTask = sut.getArtifact(with: objectID) { _ in } as! MockURLSessionTask
        
        // then
        XCTAssertTrue(mockTask.calledResume)
    }
    
    
    func test_getExhibit_givenHTTPStatusError_callsCompletionWithError() {
        // when
        let result: (calledCompletion: Bool, exhibit: ExhibitData?, error: WellCulturedError?) = whenGetExhibit(statusCode: 500)
        
        // then
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.exhibit)
        XCTAssertEqual(result.error, .invalidResponse)
    }
    
    
    func test_getArtifact_givenHTTPStatusError_callsCompletionWithError() {
        // when
        let result: (calledCompletion: Bool, artifact: ArtifactData?, error: WellCulturedError?) = whenGetArtifact(statusCode: 500)
        
        // then
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.artifact)
        XCTAssertEqual(result.error, .invalidResponse)
    }
    
    
    func test_getExhibit_givenError_callsCompletionWithError() {
        // given
        let expectedError: WellCulturedError = .unableToComplete
        
        // when
        let result: (calledCompletion: Bool, exhibit: ExhibitData?, error: WellCulturedError?) = whenGetExhibit(error: expectedError)
        
        // then
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.exhibit)
        XCTAssertEqual(result.error, expectedError)
    }
    
    
    func test_getArtifact_givenError_callsCompletionWithError() {
        // given
        let expectedError = WellCulturedError.unableToComplete
        
        // when
        let result: (calledCompletion: Bool, artifact: ArtifactData?, error: WellCulturedError?) = whenGetArtifact(error: expectedError)
        
        // then
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.artifact)
        XCTAssertEqual(result.error, expectedError)
    }
    
    
    func test_getExhibit_givenValidJSON_callsCompletionWithExhibit() throws {
        // given
        let data = try Data.fromJSON(fileName: "GET_Exhibit_Response")
        let decoder = JSONDecoder()
        let exhibit = try decoder.decode(ExhibitData.self, from: data)
        
        // when
        let result: (calledCompletion: Bool, exhibit: ExhibitData?, error: WellCulturedError?) = whenGetExhibit(data: data)
        
        // then
        XCTAssertTrue(result.calledCompletion)
        XCTAssertEqual(result.exhibit, exhibit)
        XCTAssertNil(result.error)
    }
    
    
    func test_getArtifact_givenValidJSON_callsCompletionWithArtifact() throws {
        // given
        let data = try Data.fromJSON(fileName: "GET_Artifact_Response")
        let decoder = JSONDecoder()
        let artifact = try decoder.decode(ArtifactData.self, from: data)
        
        // when
        let result: (calledCompletion: Bool, artifact: ArtifactData?, error: WellCulturedError?) = whenGetArtifact(data: data)
        
        // then
        XCTAssertTrue(result.calledCompletion)
        XCTAssertEqual(result.artifact, artifact)
        XCTAssertNil(result.error)
    }
    
    
    func test_getExhibit_givenInvalidJSON_callsCompletionWithError() throws {
        // given
        let data = try Data.fromJSON(fileName: "GET_Exhibit_MissingValuesResponse")
        var expectedError: WellCulturedError!
        let decoder = JSONDecoder()
        
        do {
            _ = try decoder.decode(ExhibitData.self, from: data)
        } catch {
            expectedError = WellCulturedError.invalidParse
        }
        
        // when
        let result: (calledCompletion: Bool, exhibit: ExhibitData?, error: WellCulturedError?) = whenGetExhibit(data: data)
        
        // then
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.exhibit)
        XCTAssertEqual(result.error, expectedError)
    }
    
    
    func test_getArtifact_givenInvalidJSON_callsCompletionWithError() throws {
        // given
        let data = try Data.fromJSON(fileName: "GET_Exhibit_MissingValuesResponse")
        var expectedError: WellCulturedError!
        let decoder = JSONDecoder()
        
        do {
            _ = try decoder.decode(ArtifactData.self, from: data)
        } catch {
            expectedError = WellCulturedError.invalidParse
        }
        
        // when
        let result: (calledCompletion: Bool, artifact: ArtifactData?, error: WellCulturedError?) = whenGetArtifact(data: data)
        
        // then
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.artifact)
        XCTAssertEqual(result.error, expectedError)
    }
    
    
    func test_getExhibit_givenHTTPStatusError_dispatchesToResponseQueue() {
        verifyGetExhibitDispatchedToMain(statusCode: 500)
    }
    
    
    func test_getArtifact_givenHTTPStatusError_dispatchesToResponseQueue() {
        verifyGetArtifactDispatchedToMain(statusCode: 500)
    }
    
    
    func test_getExhibit_givenError_dispatchesToResponseQueue() {
        // given
        let error = NSError(domain: "com.WellCulturedTests", code: 42)
        
        // then
        verifyGetExhibitDispatchedToMain(error: error)
    }
    
    
    func test_getArtifact_givenError_dispatchesToResponseQueue() {
        // given
        let error = NSError(domain: "com.WellCulturedTests", code: 42)
        
        // then
        verifyGetArtifactDispatchedToMain(error: error)
    }
    
    
    func test_getExhibit_givenGoodResponse_dispatchesToResponseQueue() throws {
        // given
        let data = try Data.fromJSON(fileName: "GET_Exhibit_Response")
        
        // then
        verifyGetExhibitDispatchedToMain(data: data)
    }
    
    
    func test_getArtifact_givenGoodResponse_dispatchesToResponseQueue() throws {
        // given
        let data = try Data.fromJSON(fileName: "GET_Artifact_Response")
        
        // then
        verifyGetArtifactDispatchedToMain(data: data)
    }
    
    
    func test_getExhibit_givenInvalidResponse_dispatchesToResponseQueue() throws {
        // given
        let data = try Data.fromJSON(fileName: "GET_Exhibit_MissingValuesResponse")
        
        // then
        verifyGetExhibitDispatchedToMain(data: data)
    }
    
    
    func test_getArtifact_givenInvalidResponse_dispatchesToResponseQueue() throws {
        // given
        let data = try Data.fromJSON(fileName: "GET_Artifact_MissingValuesResponse")
        
        // then
        verifyGetArtifactDispatchedToMain(data: data)
    }
}
