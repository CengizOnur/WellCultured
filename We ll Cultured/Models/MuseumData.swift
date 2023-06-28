//
//  MuseumData.swift
//  We ll Cultured
//
//  Created by Onur Akdogan on 22.05.2022.
//

import Foundation

struct ExhibitData: Codable, Equatable {
    let total: Int
    let objectIDs: [Int]
}


struct ArtifactData: Codable, Equatable {
    let objectID: Int
    let primaryImageSmall: String?
    let title: String
    let objectURL: String
}
