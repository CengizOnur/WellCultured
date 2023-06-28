//
//  DatabaseManager.swift
//  We ll Cultured
//
//  Created by Onur Akdogan on 22.05.2022.
//

import Foundation
import RealmSwift

protocol DatabaseService {
    func saveArtifact(_ artifact: ArtifactModel) -> Bool
    func queryArtifacts() -> [ArtifactModel]
    func checkArtifactIsSaved(_ artifact: ArtifactModel) -> Bool
    func removeArtifact(_ artifact: ArtifactModel) -> Bool
}

final class DatabaseManager: DatabaseService {
    
    static let shared = DatabaseManager()
    
    private let realm = try! Realm()
    private var inspiringArtifact: Results<InspiringArtifact>?
    private var artifacts: [ArtifactModel] = []
    
    
    func saveArtifact(_ artifact: ArtifactModel) -> Bool {
        do {
            try realm.write {
                let artifactToSave = InspiringArtifact()
                artifactToSave.objectId = artifact.objectId
                artifactToSave.title = artifact.title
                artifactToSave.imgUrl = artifact.imageUrl ?? "no image"
                artifactToSave.link = artifact.linkToWebsite
                realm.add(artifactToSave)
            }
            return true
        } catch {
            return false
        }
    }
    
    
    func queryArtifacts() -> [ArtifactModel] {
        artifacts = []
        inspiringArtifact = realm.objects(InspiringArtifact.self).sorted(byKeyPath: "title", ascending: true)
        if let savedArtifacts = inspiringArtifact {
            for i in 0..<savedArtifacts.count {
                let savedArtifact = savedArtifacts[i]
                let artifact = ArtifactModel(objectId: savedArtifact.objectId, imageUrl: savedArtifact.imgUrl, title: savedArtifact.title, linkToWebsite: savedArtifact.link)
                artifacts.append(artifact)
            }
            return artifacts
        } else {
            return []
        }
    }
    
    
    func checkArtifactIsSaved(_ artifact: ArtifactModel) -> Bool {
        return artifacts.contains(artifact) ? true : false
    }
    
    
    func removeArtifact(_ artifact: ArtifactModel) -> Bool {
        let artifactIndex = artifacts.firstIndex(where: {$0 == artifact})
        if let artifactToDelete = self.inspiringArtifact?[artifactIndex!] {
            do {
                try realm.write {
                    realm.delete(artifactToDelete)
                }
                return true
            } catch {
                return false
            }
        }
        return false
    }
}
