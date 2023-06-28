//
//  ExhibitionViewControllerTests.swift
//  We ll Cultured UnitTests
//
//  Created by Onur Akdogan on 30.06.2022.
//

@testable import We_ll_Cultured
import XCTest

final class ExhibitionViewControllerTests: XCTestCase {
    
    var sut: ExhibitionViewController!
    
    var mockNetworkClient: MockWellCulturedService!
    var mockImageClient: MockImageService!
    var mockDatabaseManager: MockDatabaseManager!
    
    var query: String!
    var objectID: Int!
    
    var exhibitData: ExhibitData!
    var artifactData: ArtifactData!
    var artifactDataArray: [ArtifactData]!
    var expectedExhibitModel: ExhibitModel!
    var expectedArtifacts: [ArtifactModel]!
    
    enum DataOptions {
        case optionOne
        case optionTwo
    }
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        query = "flower"
        objectID = 11207
        sut = ExhibitionViewController()
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        expectedArtifacts = nil
        expectedExhibitModel = nil
        artifactDataArray = nil
        artifactData = nil
        exhibitData = nil
        mockNetworkClient = nil
        mockImageClient = nil
        mockDatabaseManager = nil
        query = nil
        objectID = nil
        sut = nil
        super.tearDown()
    }
    
    
    // MARK: - Given
    
    func givenMockNetworkClient() {
        mockNetworkClient = MockWellCulturedService()
        sut.networkClient = mockNetworkClient
    }
    
    
    func givenMockImageNetworkClient() {
        mockImageClient = MockImageService()
        sut.imageClient = mockImageClient
    }
    
    
    func givenMockDatabaseManager() {
        mockDatabaseManager = MockDatabaseManager()
        sut.databaseManager = mockDatabaseManager
    }
    
    
    // MARK: - Given Data
    
    func givenExhibitData(option: DataOptions = .optionOne) {
        var data: Data
        if option == .optionOne {
            data = try! Data.fromJSON(fileName: "GET_Exhibit_Response")
        } else {
            data = try! Data.fromJSON(fileName: "GET_Exhibit_Response_AlternativeOne")
        }
        let decoder = JSONDecoder()
        exhibitData = try! decoder.decode(ExhibitData.self, from: data)
    }
    
    
    func givenArtifactData(option: DataOptions = .optionOne) {
        var data: Data
        if option == .optionOne {
            data = try! Data.fromJSON(fileName: "GET_Artifact_Response")
        } else {
            data = try! Data.fromJSON(fileName: "GET_Artifact_Response_AlternativeOne")
        }
        let decoder = JSONDecoder()
        artifactData = try! decoder.decode(ArtifactData.self, from: data)
    }
    
    
    func givenArtifactDataArray(numberOfArtifacts: Int, option: DataOptions = .optionOne) {
        givenArtifactData(option: option)
        artifactDataArray = []
        for i in 0..<numberOfArtifacts {
            let artifactData = ArtifactData(
                objectID: artifactData.objectID + i,
                primaryImageSmall: artifactData.primaryImageSmall,
                title: artifactData.title + "\(i)",
                objectURL: artifactData.objectURL)
            artifactDataArray.append(artifactData)
        }
    }
    
    
    // MARK: - Expected Model
    
    func givenExpectedExhibitModel(option: DataOptions = .optionOne) {
        givenExhibitData(option: option)
        expectedExhibitModel = ExhibitModel(exhibitData: exhibitData)
    }
    
    
    //    func expectedArtifactModel(option: DataOptions = .optionOne) -> ArtifactModel {
    //        return ArtifactModel(artifactData: givenArtifactData(option: option))
    //    }
    
    
    func expectedArtifacts(option: DataOptions = .optionOne) {
        givenExpectedExhibitModel(option: option)
        let expectedNumberOfArtifactsInGroup = min(
            expectedExhibitModel.numberOfObjects,
            sut.maxNumberOfElementsInGroup)
        givenArtifactDataArray(numberOfArtifacts: expectedNumberOfArtifactsInGroup, option: option)
        expectedArtifacts = artifactDataArray.map { ArtifactModel(artifactData: $0) }
    }
    
    
    // MARK: - When
    
    func givenGotExhibitSetup(option: DataOptions = .optionOne) {
        givenMockNetworkClient()
        givenExpectedExhibitModel(option: option)
        
        sut.getExhibit(about: query)
        mockNetworkClient.getExhibitCompletion(.success(exhibitData))
    }
    
    
    func givenGotArtifactsSetup(line: UInt = #line, option: DataOptions = .optionOne) {
        givenGotExhibitSetup(option: option)
        
        let expectation = expectation(description: "getArtifact to be finished.")
        sut.gotArtifacts { expectation.fulfill() }
        
        let numberOfArtifactsInGroup = sut.groups[sut.currentGroup]!.count
        givenArtifactDataArray(numberOfArtifacts: numberOfArtifactsInGroup, option: option)
        
        for i in 0..<numberOfArtifactsInGroup {
            mockNetworkClient.getArtifactCompletion(.success(artifactDataArray[i]))
        }
        
        waitForExpectations(timeout: 0.5) { _ in
            print("Error on line: \(line)")
        }
    }
    
    
    // MARK: - Services - Tests
    
    func test_networkClient_isWellCulturedService() {
        XCTAssertTrue((sut.networkClient as AnyObject) is WellCulturedService)
    }
    
    
    func test_imageClient_isImageService() {
        XCTAssertTrue((sut.imageClient as AnyObject) is ImageService)
    }
    
    
    func test_databaseManager_isDatabaseService() {
        XCTAssertTrue((sut.databaseManager as AnyObject) is DatabaseService)
    }
    
    
    // MARK: - Static Properties - Tests
    
    func test_networkClient_setToWellCulturedClient() {
        XCTAssertTrue((sut.networkClient as? WellCulturedClient) === WellCulturedClient.shared)
    }
    
    
    func test_imageClient_setToSharedImageClient() {
        XCTAssertTrue((sut.imageClient as? ImageClient) === ImageClient.shared)
    }
    
    
    func test_databaseManager_setToDatabaseManager() {
        XCTAssertTrue((sut.databaseManager as? DatabaseManager) === DatabaseManager.shared)
    }
    
    
    // MARK: - Instance Properties - Tests
    
    func test_exhibitAndArtifactModels_setToNil() {
        XCTAssertNil(sut.exhibitModel, "exhibitModel is not set to nil.")
        XCTAssertNil(sut.artifactModel, "artifactModel is not set to nil.")
    }
    
    
    func test_artifacts_setToEmptyArray() {
        XCTAssertEqual(sut.objectIDs.count, 0, "artifacts is not empty.")
        XCTAssertEqual(sut.artifacts.count, 0, "artifacts is not empty.")
    }
    
    
    func test_tasks_setToNilOrEmpty() {
        XCTAssertNil(sut.exhibitDataTask, "exhibitDataTask is not set to nil.")
        XCTAssertNil(sut.artifactDataTask, "artifactDataTask is not set to nil.")
        XCTAssertEqual(sut.artifactDataTasks.count, 0, "artifactDataTasks is not empty.")
    }
    
    
    // MARK: - View Life Cycle - Tests
    
    func test_viewDidLoad_calls_getExhibit() {
        // given
        givenMockNetworkClient()
        sut.query = query
        
        // when
        sut.viewDidLoad()
        
        //then
        XCTAssertEqual(mockNetworkClient.getExhibitCallCount, 1)
        XCTAssertNotNil(sut.exhibitDataTask)
        XCTAssertTrue(sut.exhibitDataTask === mockNetworkClient.getExhibitDataTask)
    }
    
    
    func test_getExhibit_ifAlreadyGotExhibit_doesntCallAgain() {
        // given
        givenMockNetworkClient()
        
        // when
        sut.getExhibit(about: query)
        sut.getExhibit(about: query)
        
        // then
        XCTAssertEqual(mockNetworkClient.getExhibitCallCount, 1)
        XCTAssertNotNil(sut.exhibitDataTask)
    }
    
    
    func test_getExhibit_completionMakesExhibitDataTaskNil() {
        // given
        givenMockNetworkClient()
        
        // when
        sut.getExhibit(about: query)
        mockNetworkClient.getExhibitCompletion(.failure(.invalidResponse))
        
        // then
        XCTAssertNil(sut.exhibitDataTask)
    }
    
    
    func test_getExhibit_givenExhibitResponse_setsExhibitModel() {
        // given
        givenMockNetworkClient()
        givenExhibitData()
        givenExpectedExhibitModel()
        
        // when
        sut.getExhibit(about: query)
        mockNetworkClient.getExhibitCompletion(.success(exhibitData))
        
        // then
        XCTAssertNil(sut.exhibitDataTask)
        XCTAssertEqual(sut.objectIDs, expectedExhibitModel.objectIDs)
        XCTAssertEqual(sut.exhibitModel, expectedExhibitModel)
    }
    
    
    func test_viewDidLoad_calls_getArtifactsThroughGetExhibit() {
        // given
        givenMockNetworkClient()
        givenExhibitData()
        sut.query = query
        
        // when
        sut.viewDidLoad()
        mockNetworkClient.getExhibitCompletion(.success(exhibitData)) // It calls getArtifacts through getExhibit.
        
        // then
        XCTAssertNotNil(sut.artifactDataTask)
        XCTAssertTrue(sut.artifactDataTask === mockNetworkClient.getArtifactDataTask)
    }
    
    
    func test_getExhibit_calls_getArtifactCorrectNumberOfTimesForOptionOne() {
        // when
        givenGotExhibitSetup()
        
        let expectedArtifactNumberInGroup = min(
            expectedExhibitModel.numberOfObjects,
            sut.maxNumberOfElementsInGroup)
        
        let artifactNumberInGroup = min(
            sut.exhibitModel?.numberOfObjects ?? 0,
            sut.maxNumberOfElementsInGroup)
        
        // then
        XCTAssertEqual(artifactNumberInGroup, expectedArtifactNumberInGroup)
        XCTAssertEqual(mockNetworkClient.getArtifactCallCount, expectedArtifactNumberInGroup)
        XCTAssertNotNil(sut.artifactDataTask)
        XCTAssertEqual(sut.artifactDataTasks.count, expectedArtifactNumberInGroup)
    }
    
    
    func test_getExhibit_calls_getArtifactCorrectNumberOfTimesForOptionTwo() {
        // when
        givenGotExhibitSetup(option: .optionTwo)
        
        let expectedArtifactNumberInGroup = min(
            expectedExhibitModel.numberOfObjects,
            sut.maxNumberOfElementsInGroup)
        
        let artifactNumberInGroup = min(
            sut.exhibitModel?.numberOfObjects ?? 0,
            sut.maxNumberOfElementsInGroup)
        
        // then
        XCTAssertEqual(artifactNumberInGroup, expectedArtifactNumberInGroup)
        XCTAssertEqual(mockNetworkClient.getArtifactCallCount, expectedArtifactNumberInGroup)
        XCTAssertNotNil(sut.artifactDataTask)
        XCTAssertEqual(sut.artifactDataTasks.count, expectedArtifactNumberInGroup)
    }
    
    
    func test_getArtifacts_ifAlreadyCalledArtifacts_doesntCallAgain() {
        // when
        /// Through getExhibit (by group, n times) with completion:
        /// - mockNetworkClient.getExhibitCompletion(.success(exhibitData))
        givenGotExhibitSetup()
        
        /// Manually (by group, n times)
        sut.getArtifacts(in: sut.groups, which: sut.currentGroup)
        
        /// Manually (by one time)
        sut.getArtifact(with: objectID) { _ in }
        
        // then
        /// Should not be n x 2 + 1 times
        XCTAssertNotEqual(
            mockNetworkClient.getArtifactCallCount,
            2 * (sut.groups[sut.currentGroup]!.count) + 1)
        
        /// Should be n times through getExhibit only
        XCTAssertEqual(
            mockNetworkClient.getArtifactCallCount,
            sut.groups[sut.currentGroup]?.count)
        
        XCTAssertNotNil(sut.artifactDataTask)
        XCTAssertFalse(sut.isGroupShownOnCollectionView)
    }
    
    
    func test_getArtifacts_completionMakesArtifactDataTaskNil() {
        // when
        givenGotArtifactsSetup()
        let artifactNumberInGroup = sut.artifacts.count
        
        // then
        XCTAssertEqual(mockNetworkClient.getArtifactCallCount, artifactNumberInGroup)
        XCTAssertNil(sut.artifactDataTask)
        XCTAssertEqual(sut.artifactDataTasks.count, 0)
        XCTAssertTrue(sut.isGroupShownOnCollectionView)
    }
    
    
    func test_getArtifacts_givenArtifactResponses_setsArtifactModels() {
        // given
        expectedArtifacts()
        
        // when
        givenGotArtifactsSetup()
        
        // then
        XCTAssertEqual(sut.artifacts, expectedArtifacts)
    }
    
    
    func test_getArtifacts_givenArtifactResponses_calls_showImage() {
        // given
        givenMockImageNetworkClient()
        
        // when
        givenGotArtifactsSetup()
        let artifact = sut.artifacts[0]
        
        // then
        XCTAssertEqual(mockImageClient.setImageCallCount, 1)
        XCTAssertEqual(mockImageClient.receivedImageView, sut.containerView.artifactImageView)
        XCTAssertEqual(mockImageClient.receivedURL.absoluteString, artifact?.imageUrl)
        XCTAssertEqual(mockImageClient.receivedPlaceholder.pngData(), UIImage(systemName: "photo")!.pngData())
        
        XCTAssertEqual(sut.containerView.artifactLabel.text, artifact?.title)
    }
    
    
    func test_swiping_calls_showImage() {
        // given
        givenMockImageNetworkClient()
        expectedArtifacts()
        sut.artifacts = expectedArtifacts
        let artifactOne = sut.artifacts[0]
        let artifactTwo = sut.artifacts[1]
        sut.showImage(from: artifactOne)
        
        // when swipe to next
        sut.goToNextArtifact()
        XCTAssertEqual(mockImageClient.setImageCallCount, 2)
        XCTAssertEqual(mockImageClient.receivedImageView, sut.containerView.artifactImageView)
        XCTAssertEqual(mockImageClient.receivedURL.absoluteString, artifactTwo?.imageUrl)
        XCTAssertEqual(mockImageClient.receivedPlaceholder.pngData(), UIImage(systemName: "photo")!.pngData())
        
        XCTAssertEqual(sut.containerView.artifactLabel.text, artifactTwo?.title)
        
        // when swipe to previous
        sut.goToPreviousArtifact()
        XCTAssertEqual(mockImageClient.setImageCallCount, 3)
        XCTAssertEqual(mockImageClient.receivedImageView, sut.containerView.artifactImageView)
        XCTAssertEqual(mockImageClient.receivedURL.absoluteString, artifactOne?.imageUrl)
        XCTAssertEqual(mockImageClient.receivedPlaceholder.pngData(), UIImage(systemName: "photo")!.pngData())
        
        XCTAssertEqual(sut.containerView.artifactLabel.text, artifactOne?.title)
    }
    
    
    func test_swiping_whenOnFirstAndLastArtifactsInGroup_showsCorrectArtifact() {
        givenMockImageNetworkClient()
        expectedArtifacts()
        sut.artifacts = expectedArtifacts
        let numberOfArtifactsInTheGroup = sut.artifacts.count
        let firstArtifactInGroup = sut.artifacts[0]
        let lastArtifactInGroup = sut.artifacts[numberOfArtifactsInTheGroup - 1]
        sut.showImage(from: firstArtifactInGroup)
        
        // when on first artifact
        XCTAssertEqual(mockImageClient.setImageCallCount, 1)
        XCTAssertEqual(mockImageClient.receivedURL.absoluteString, firstArtifactInGroup?.imageUrl)
        
        // when swipe to previous one when it is already on the first one
        sut.goToPreviousArtifact()
        XCTAssertEqual(mockImageClient.setImageCallCount, 1)
        XCTAssertEqual(mockImageClient.receivedURL.absoluteString, firstArtifactInGroup?.imageUrl)
        
        // swipe to last artifact
        (1..<numberOfArtifactsInTheGroup).forEach { _ in sut.goToNextArtifact() }
        
        // when on the last artifact
        XCTAssertEqual(numberOfArtifactsInTheGroup, mockImageClient.setImageCallCount)
        XCTAssertEqual(lastArtifactInGroup?.imageUrl, mockImageClient.receivedURL.absoluteString)
        XCTAssertEqual(sut.currentGroup, 1)
        
        // swipe to next one when it is already on the last one, if it doesn't match condition to call artifacts in second group
        sut.goToNextArtifact()
        XCTAssertEqual(numberOfArtifactsInTheGroup, mockImageClient.setImageCallCount)
        XCTAssertEqual(lastArtifactInGroup?.imageUrl, mockImageClient.receivedURL.absoluteString)
        XCTAssertEqual(sut.currentGroup, 1)
    }
    
    
    func test_swipingToNext_whenOnLastArtifactsInGroup_calls_getArtifactsInNextGroup() {
        givenMockImageNetworkClient()
        givenGotExhibitSetup()
        expectedArtifacts()
        sut.artifacts = expectedArtifacts
        let numberOfArtifactsInTheGroup = sut.artifacts.count
        let firstArtifactInGroup = sut.artifacts[0]
        let lastArtifactInGroup = sut.artifacts[numberOfArtifactsInTheGroup - 1]
        sut.showImage(from: firstArtifactInGroup)
        
        // swipe to last artifact
        (1..<numberOfArtifactsInTheGroup).forEach { _ in sut.goToNextArtifact() }
        
        // when on the last artifact
        XCTAssertEqual(numberOfArtifactsInTheGroup, mockImageClient.setImageCallCount)
        XCTAssertEqual(lastArtifactInGroup?.imageUrl, mockImageClient.receivedURL.absoluteString)
        XCTAssertEqual(sut.currentGroup, 1)
        
        // swipe to next one when it is already on the last one, if it matches condition to call artifacts in second group
        sut.isGroupShownOnCollectionView = true
        sut.goToNextArtifact()
        XCTAssertEqual(sut.currentGroup, 2)
    }
    
    
    // MARK: - Database - Tests
    
    func test_viewWillAppear_fetchesSavedArtifacts() {
        // given
        givenMockDatabaseManager()
        expectedArtifacts()
        mockDatabaseManager.database = expectedArtifacts
        
        // when
        sut.viewWillAppear(true)
        
        // then
        XCTAssertEqual(mockDatabaseManager.exhibits, mockDatabaseManager.database, "viewWillAppear doesn't fetch artifacts from database")
    }
    
    
    func test_viewWillAppear_checksIfCurrentArtifactIsSaved() {
        givenMockDatabaseManager()
        expectedArtifacts()
        sut.artifacts = expectedArtifacts
        
        // when not saved
        sut.viewWillAppear(true)
        XCTAssertEqual(sut.containerView.inspiringButton.imageView?.tintColor, UIColor.systemGray, "viewWillAppear doesn't check whether current artifact is saved")
        
        // when saved
        expectedArtifacts()
        mockDatabaseManager.database = expectedArtifacts
        sut.viewWillAppear(true)
        XCTAssertEqual(sut.containerView.inspiringButton.imageView?.tintColor, UIColor.systemRed, "viewWillAppear doesn't check whether current artifact is saved")
    }
    
    
    func test_inspiringButton_savesOrRemovesCurrentArtifact() {
        // given
        givenMockDatabaseManager()
        expectedArtifacts()
        sut.artifacts = expectedArtifacts
        
        // when not saved
        sut.viewWillAppear(true)
        XCTAssertEqual(mockDatabaseManager.database.count, 0)
        XCTAssertEqual(sut.containerView.inspiringButton.imageView?.tintColor, .systemGray)
        
        // when add to database
        sut.containerView.inspiringButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mockDatabaseManager.database[0], sut.artifacts[0], "inspiringButton doesn't add to database")
        XCTAssertEqual(sut.containerView.inspiringButton.imageView?.tintColor, .systemRed, "inspiringButton doesn't add to database")
        
        // when remove from database
        sut.containerView.inspiringButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(mockDatabaseManager.database.count, 0, "inspiringButton doesn't remove from database")
        XCTAssertEqual(sut.containerView.inspiringButton.imageView?.tintColor, .systemGray, "inspiringButton doesn't remove from database")
    }
    
    
    // MARK: - CollectionView - Tests
    
    func test_collectionView_onSet_registersArtifactCell() {
        // when
        let cell = sut.collectionView.dequeueReusableCell(withReuseIdentifier: ArtifactCell.reuseID, for: IndexPath())
        
        // then
        XCTAssertTrue(cell is ArtifactCell)
    }
    
    
    func test_onSet_configureDataSource() {
        XCTAssertNotNil(sut.dataSource, "DataSource didn't set when view loaded.")
    }
}
