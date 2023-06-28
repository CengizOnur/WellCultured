//
//  ArtifactCell.swift
//  We ll Cultured
//
//  Created by Onur Akdogan on 22.05.2022.
//

import UIKit

final class ArtifactCell: UICollectionViewCell {
    
    static let reuseID = "ArtifactCell"
    var imageClient: ImageService = ImageClient.shared
    
    let artifactImageView = WllCArtifactImageView(frame: .zero)
    let artifactLabel = WllCLabel(textAlignment: .center, font: .systemFont(ofSize: 16))
    
    var actualUrlString: String?
    var actualArtifactTitle: String?
    
    private let padding: CGFloat = 1
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func set(artifact: ArtifactModel) {
        artifactImageView.image = nil
        actualUrlString = artifact.imageUrl
        actualArtifactTitle = artifact.title
        let url = URL(string: actualUrlString!) ?? URL(string: "unavailableImage")!
        
        imageClient.setImage(on: artifactImageView, fromURL: url, withPlaceholder: UIImage(systemName: "photo"))
        DispatchQueue.main.async { self.artifactLabel.text = self.actualArtifactTitle }
    }
    
    
    private func configure() {
        self.contentView.addSubview(artifactImageView)
        self.contentView.addSubview(artifactLabel)
        artifactLabel.translatesAutoresizingMaskIntoConstraints = false
        artifactImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            artifactImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            artifactImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            artifactImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            artifactImageView.bottomAnchor.constraint(equalTo: artifactLabel.topAnchor, constant: -padding),
            
            artifactLabel.heightAnchor.constraint(equalToConstant: 40),
            artifactLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            artifactLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            artifactLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
        ])
    }
}
