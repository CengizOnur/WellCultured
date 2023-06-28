//
//  MockWellCulturedService.swift
//  We ll Cultured UnitTests
//
//  Created by Onur Akdogan on 30.06.2022.
//

@testable import We_ll_Cultured
import Foundation

final class MockWellCulturedService: WellCulturedService {
    
    var baseURL = URL(string: "https://example.com/api/")!
    
    var getExhibitCallCount = 0
    var getArtifactCallCount = 0
    
    var getExhibitCompletion: ((Result<ExhibitData, WellCulturedError>) -> Void)!
    var getArtifactCompletion: ((Result<ArtifactData, WellCulturedError>) -> Void)!
    
    lazy var getExhibitDataTask = MockURLSessionTask(
        completionHandler: { _, _, _ in },
        url: URL(string: "exhibit", relativeTo: baseURL)!,
        queue: nil)
    
    lazy var getArtifactDataTask = MockURLSessionTask(
        completionHandler: { _, _, _ in },
        url: URL(string: "artifact", relativeTo: baseURL)!,
        queue: nil)
    
    
    func getExhibit(about: String, completion: @escaping (Result<ExhibitData, WellCulturedError>) -> Void) -> URLSessionTaskProtocol {
        getExhibitCallCount += 1
        getExhibitCompletion = completion
        return getExhibitDataTask
    }
    
    
    func getArtifact(with objectID: Int, completion: @escaping (Result<ArtifactData, WellCulturedError>) -> Void) -> URLSessionTaskProtocol {
        getArtifactCallCount += 1
        getArtifactCompletion = completion
        return getArtifactDataTask
    }
}

