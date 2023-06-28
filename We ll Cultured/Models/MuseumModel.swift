//
//  MuseumModel.swift
//  We ll Cultured
//
//  Created by Onur Akdogan on 22.05.2022.
//

import Foundation
import RealmSwift

struct ExhibitModel: Equatable {
    let numberOfObjects: Int
    let objectIDs: [Int]
    
    init(exhibitData: ExhibitData) {
        self.numberOfObjects = exhibitData.total
        self.objectIDs = exhibitData.objectIDs
    }
}


struct ArtifactModel: Hashable {
    
    let objectId: Int
    let imageUrl: String?
    let title: String
    let linkToWebsite: String
    
    init(artifactData: ArtifactData) {
        self.objectId = artifactData.objectID
        self.imageUrl = artifactData.primaryImageSmall
        self.title = artifactData.title
        self.linkToWebsite = artifactData.objectURL
    }
    
    init(objectId: Int, imageUrl: String?, title: String, linkToWebsite: String) {
        self.objectId = objectId
        self.imageUrl = imageUrl
        self.title = title
        self.linkToWebsite = linkToWebsite
    }
}


final class InspiringArtifact: Object {
    @objc dynamic var objectId: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var imgUrl: String = ""
    @objc dynamic var link: String = ""
}
