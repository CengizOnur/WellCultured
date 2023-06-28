//
//  MockDatabaseManager.swift
//  We ll Cultured UnitTests
//
//  Created by Onur Akdogan on 18.07.2022.
//

import Foundation
@testable import We_ll_Cultured

final class MockDatabaseManager: DatabaseService {
    
    var database: [ArtifactModel] = []
    var exhibits: [ArtifactModel] = []
    
    
    func saveArtifact(_ artifact: ArtifactModel) -> Bool {
        database.append(artifact)
        return true
    }
    
    
    func queryArtifacts() -> [ArtifactModel] {
        exhibits = database
        return exhibits
    }
    
    
    func checkArtifactIsSaved(_ artifact: ArtifactModel) -> Bool {
        return database.contains(artifact)
    }
    
    
    func removeArtifact(_ artifact: ArtifactModel) -> Bool {
        let exhibitIndex = database.firstIndex { $0 == artifact }
        if let exhibitIndex = exhibitIndex {
            database.remove(at: exhibitIndex)
            return true
        }
        return false
    }
}
