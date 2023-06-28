//
//  DiscoverViewControllerTests.swift
//  We ll Cultured UnitTests
//
//  Created by Onur Akdogan on 4.12.2022.
//

import XCTest
@testable import We_ll_Cultured

final class DiscoverViewControllerTests: XCTestCase {
    
    var sut: DiscoverViewController!
    var query = "flower"
    var searchFieldPlaceholder = "Type anything about you wonder..."
    var searchFieldAlertLikePlaceholder = "Type something"
    
    override func setUp() {
        super.setUp()
        sut = DiscoverViewController()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    
    // MARK: - Test searchField
    
    func test_textFieldShowsProperPlaceholder() {
        XCTAssertEqual(sut.searchField.text, "")
        XCTAssertEqual(sut.searchField.placeholder, searchFieldPlaceholder)
    }
    
    
    func test_whenSearchFieldIsEmptyTappedSearchButton_ShowAlert() {
        // when
        sut.searchButtonTapped()
        
        // then
        XCTAssertEqual(sut.searchField.text, "")
        XCTAssertEqual(sut.searchField.placeholder, searchFieldAlertLikePlaceholder)
    }
    
    
    func test_whenSearchFieldIsNotEmptyTappedSearchButton_DoesntShowAlert() {
        // given
        sut.searchField.text = query
        
        // when
        sut.searchButtonTapped()
        
        // then
        XCTAssertEqual(sut.searchField.text, query)
        XCTAssertEqual(sut.searchField.placeholder, searchFieldPlaceholder)
    }
    
}
