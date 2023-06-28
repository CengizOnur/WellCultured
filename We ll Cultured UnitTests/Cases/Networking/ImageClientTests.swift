//
//  ImageClientTests.swift
//  We ll Cultured UnitTests
//
//  Created by Onur Akdogan on 2.07.2022.
//

@testable import We_ll_Cultured
import XCTest

final class ImageClientTests: XCTestCase {
    
    var sut: ImageClient!
    var mockSession: MockURLSession!
    var service: ImageService {
        return sut as ImageService
    }
    
    var url: URL!
    var imageView: UIImageView!
    
    var receivedTask: MockURLSessionTask?
    var receivedError: WellCulturedError?
    var receivedImage: UIImage?
    var calledCompletion: Bool!
    
    var placeholderImage: UIImage!
    var unavailableImage: UIImage!
    var expectedImage: UIImage!
    var expectedError: WellCulturedError!
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        url = URL(string: "https://example.com/image")!
        imageView = UIImageView()
        calledCompletion = false
        sut = ImageClient(session: mockSession, responseQueue: nil)
    }
    
    override func tearDown() {
        receivedTask = nil
        receivedError = nil
        receivedImage = nil
        calledCompletion = nil
        placeholderImage = nil
        unavailableImage = nil
        expectedImage = nil
        expectedError = nil
        imageView = nil
        url = nil
        mockSession = nil
        sut = nil
        super.tearDown()
    }
    
    
    // MARK: - Given
    
    func givenPlaceholderImage() {
        placeholderImage = UIImage(named: "placeholderImage")!
    }
    
    
    /// There are some artifacts that does not have image to get from Museum API.
    func givenUnavailableImageUrl() {
        url = URL(string: "unavailableImage")
    }
    
    
    func givenUnavailableImage() {
        unavailableImage = UIImage(named: "unavailableImage")!
    }
    
    
    func givenExpectedImage() {
        expectedImage = UIImage(named: "expectedImage")!
    }
    
    
    func givenExpectedError() {
        expectedError = .unableToComplete
    }
    
    
    // MARK: - When
    
    func whenDownloadImage(image: UIImage? = nil, statusCode: Int = 200, error: Error? = nil) {
        receivedTask = sut.downloadImage(fromURL: url) { result in
            self.calledCompletion = true
            
            switch result {
            case .success(let image):
                self.receivedImage = image
            case .failure(let error):
                self.receivedError = error
            }
        } as? MockURLSessionTask
        
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        guard let receivedTask = receivedTask else { return }
        
        receivedTask.completionHandler(image?.pngData(), response, error)
    }
    
    
    func whenSetImage(image: UIImage? = nil, statusCode: Int = 200, error: Error? = nil, placeholderImage: UIImage? = nil) {
        sut.setImage(on: imageView, fromURL: url, withPlaceholder: placeholderImage)
        receivedTask = sut.cachedTaskForImageView[imageView] as? MockURLSessionTask
        
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        receivedTask?.completionHandler(image?.pngData(), response, error)
    }
    
    
    // MARK: - Then
    
    func verifyDownloadImageDispatched(image: UIImage? = nil, statusCode: Int = 200, error: Error? = nil, line: UInt = #line) {
        mockSession.givenDispatchQueue()
        sut = ImageClient(session: mockSession, responseQueue: .main)
        var receivedThread: Thread!
        let expectation = self.expectation(description: "Completion wasn't called")
        
        // when
        let dataTask = sut.downloadImage(fromURL: url) { _ in
            receivedThread = Thread.current
            expectation.fulfill()
        } as! MockURLSessionTask
        
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        dataTask.completionHandler(image?.pngData(), response, error)
        
        // then
        waitForExpectations(timeout: 0.2)
        XCTAssertTrue(receivedThread.isMainThread, line: line)
    }
    
    
    // MARK: - ImageService - Tests
    
    func test_conformsTo_ImageService() {
        XCTAssertTrue((sut as AnyObject) is ImageService)
    }
    
    
    func test_imageService_declaresDownloadImage() {
        _ = service.downloadImage(fromURL: url) { _ in }
    }
    
    
    func test_imageService_declaresSetImage() {
        // given
        givenPlaceholderImage()
        
        // then
        service.setImage(on: imageView, fromURL: url, withPlaceholder: nil)
    }
    
    
    // MARK: - Static Properties - Tests
    
    func test_shared_setsSession() {
        XCTAssertTrue(ImageClient.shared.session === URLSession.shared)
    }
    
    
    func test_shared_setsResponseQueue() {
        XCTAssertEqual(ImageClient.shared.responseQueue, .main)
    }
    
    
    // MARK: - Object Lifecycle - Tests
    
    func test_init_setsSession() {
        XCTAssertTrue(sut.session === mockSession)
    }
    
    
    func test_init_setsResponseQueue() {
        XCTAssertTrue(sut.responseQueue === nil)
    }
    
    
    // MARK: - Functionality - Tests
    
    func test_downloadImage_createsExpectedTask() {
        // when
        receivedTask = sut.downloadImage(fromURL: url) { _ in } as? MockURLSessionTask
        
        // then
        XCTAssertEqual(receivedTask?.url, url)
    }
    
    
    func test_downloadImage_callsResumeOnTask() {
        // when
        receivedTask = sut.downloadImage(fromURL: url) { _ in } as? MockURLSessionTask
        
        // then
        XCTAssertTrue(receivedTask?.calledResume ?? false)
    }
    
    
    func test_downloadImage_givenHTTPStatusError_callsCompletionWithError() {
        // given
        let statusCode = 500
        expectedError = .invalidResponse
        
        // when
        whenDownloadImage(statusCode: statusCode)
        
        // then
        XCTAssertTrue(calledCompletion)
        XCTAssertNil(receivedImage)
        XCTAssertEqual(receivedError, expectedError)
    }
    
    
    func test_downloadImage_givenError_callsCompletionWithError() {
        // given
        givenExpectedError()
        
        // when
        whenDownloadImage(error: expectedError)
        
        // then
        XCTAssertTrue(calledCompletion)
        XCTAssertNil(receivedImage)
        XCTAssertEqual(receivedError, expectedError)
    }
    
    
    func test_downloadImage_givenUnavailableImageUrl_callsCompletionWithError() {
        // given
        givenUnavailableImageUrl()
        expectedError = .unavailableImage
        
        // when
        whenDownloadImage()
        
        // then
        XCTAssertTrue(calledCompletion)
        XCTAssertNil(receivedImage)
        XCTAssertEqual(receivedError, expectedError)
    }
    
    
    func test_downloadImage_givenImage_callsCompletionWithImage() {
        // given
        givenExpectedImage()
        
        // when
        whenDownloadImage(image: expectedImage)
        
        // then
        XCTAssertTrue(calledCompletion)
        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedImage?.pngData(), expectedImage.pngData())
    }
    
    
    func test_downloadImage_givenHTTPStatusError_dispatchesToResponseQueue() {
        // given
        let statusCode = 500
        
        // then
        verifyDownloadImageDispatched(statusCode: statusCode)
    }
    
    
    func test_downloadImage_givenError_dispatchesToResponseQueue() {
        // given
        givenExpectedError()
        
        // then
        verifyDownloadImageDispatched(error: expectedError)
    }
    
    
    func test_downloadImage_givenImage_dispatchesToResponseQueue() {
        // given
        givenExpectedImage()
        
        // then
        verifyDownloadImageDispatched(image: expectedImage)
    }
    
    
    func test_downloadImage_givenImage_cachesImage() {
        // given
        givenExpectedImage()
        
        // when
        whenDownloadImage(image: expectedImage)
        
        // then
        XCTAssertEqual(sut.cachedImageForURL.object(forKey: url as NSURL)?.pngData(), expectedImage.pngData())
    }
    
    
    func test_downloadImage_givenCachedImage_returnsNilDataTask() {
        // given
        givenExpectedImage()
        
        // when
        whenDownloadImage(image: expectedImage)
        whenDownloadImage(image: expectedImage)
        
        // then
        XCTAssertNil(receivedTask)
    }
    
    
    func test_downloadImage_givenCachedImage_callsCompletionWithThatImage() {
        // given
        givenExpectedImage()
        
        // when
        whenDownloadImage(image: expectedImage)
        receivedImage = nil
        whenDownloadImage(image: expectedImage)
        
        // then
        XCTAssertEqual(receivedImage?.pngData(), expectedImage.pngData())
    }
    
    
    func test_setImage_cancelsExistingDataTask() {
        // given
        let task = MockURLSessionTask(completionHandler: { _, _, _ in }, url: url, queue: nil)
        sut.cachedTaskForImageView[imageView] = task
        
        // when
        sut.setImage(on: imageView, fromURL: url, withPlaceholder: nil)
        
        // then
        XCTAssertTrue(task.calledCancel)
    }
    
    
    func test_setImage_givenPlaceholder_setsPlaceholderOnImageView() {
        // given
        givenPlaceholderImage()
        
        // when
        sut.setImage(on: imageView, fromURL: url, withPlaceholder: placeholderImage)
        
        // then
        XCTAssertEqual(imageView.image?.pngData(), placeholderImage.pngData())
    }
    
    
    func test_setImage_cachesTask() {
        // when
        sut.setImage(on: imageView, fromURL: url, withPlaceholder: nil)
        receivedTask = sut.cachedTaskForImageView[imageView] as? MockURLSessionTask
        
        // then
        XCTAssertEqual(receivedTask?.url, url)
    }
    
    
    func test_setImage_removesCachedTask() {
        // when
        whenSetImage()
        
        // then
        XCTAssertNil(sut.cachedTaskForImageView[imageView])
    }
    
    
    func test_setImage_givenError_setsPlaceholderOnImageView() {
        // given
        givenExpectedError()
        givenPlaceholderImage()
        
        // when
        whenSetImage(error: expectedError, placeholderImage: placeholderImage)
        
        // then
        XCTAssertEqual(imageView.image?.pngData(), placeholderImage?.pngData())
    }
    
    
    func test_setImage_givenUnavailableImageUrl_setsUnavailableImageOnImageView() {
        // given
        givenUnavailableImageUrl()
        givenPlaceholderImage()
        givenUnavailableImage()
        
        // when
        whenSetImage(placeholderImage: placeholderImage)
        
        // then
        XCTAssertEqual(imageView.image?.pngData(), unavailableImage?.pngData())
    }
    
    
    func test_setImage_givenImage_setsImageOnImageView() {
        // given
        givenExpectedImage()
        givenPlaceholderImage()
        
        // when
        whenSetImage(image: expectedImage, placeholderImage: placeholderImage)
        
        // then
        XCTAssertNotEqual(imageView.image?.pngData(), placeholderImage.pngData())
        XCTAssertEqual(imageView.image?.pngData(), expectedImage.pngData())
    }
}
