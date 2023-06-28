//
//  WllCContainerView.swift
//  We II Cultured
//
//  Created by Onur Akdogan on 23.02.2022.
//

import UIKit

final class WllCContainerView: UIView {
    
    let artifactImageView: WllCArtifactImageView = {
        let imageView = WllCArtifactImageView(frame: .zero)
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.clear.cgColor
        return imageView
    }()
    
    let artifactLabel: WllCLabel = {
        let label = WllCLabel(textAlignment: .center, font: .systemFont(ofSize: 24))
        label.layer.cornerRadius = 5
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.clear.cgColor
        return label
    }()
    
    var detailButton: WllCButton = {
        let button = WllCButton(backgroundColor: .clear, title: nil, image: UIImage(systemName: "network"))
        button.updateButton(with: UIImage(systemName: "network"), tintColor: .clear)
        return button
    }()
    
    var inspiringButton: WllCButton = {
        let button = WllCButton(backgroundColor: .clear, title: nil, image: UIImage(systemName: "heart"))
        button.updateButton(with: UIImage(systemName: "network"), tintColor: .clear)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [UIView(), detailButton, UIView(), inspiringButton, UIView()])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let padding = 8.0
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            artifactImageView.topAnchor.constraint(equalTo: topAnchor),
            artifactImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            artifactImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            artifactImageView.bottomAnchor.constraint(equalTo: artifactLabel.topAnchor, constant: -padding),
            
            artifactLabel.leadingAnchor.constraint(equalTo: artifactImageView.leadingAnchor),
            artifactLabel.widthAnchor.constraint(equalTo: artifactImageView.widthAnchor),
            artifactLabel.heightAnchor.constraint(equalToConstant: 40),
            artifactLabel.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -2),
            
            buttonStackView.heightAnchor.constraint(equalToConstant: 40),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
        ])
    }
    
    
    private func setup() {
        self.addSubview(artifactImageView)
        self.addSubview(artifactLabel)
        self.addSubview(buttonStackView)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 10
        clipsToBounds = true
        activateConstraints()
    }
    
    
    func updateInspiringButton(isSaved: Bool) {
        if isSaved {
            inspiringButton.updateButton(with: UIImage(systemName: "heart.fill"), tintColor: .systemRed)
        } else {
            inspiringButton.updateButton(with: UIImage(systemName: "heart"), tintColor: .systemGray)
        }
    }
    
    
    // MARK: - Networking
    
    func showImage(from artifact: ArtifactModel?, imageClient: ImageService, databaseManager: DatabaseService) {
        guard let artifact = artifact else {return}
        let isSaved = databaseManager.checkArtifactIsSaved(artifact)
        updateInspiringButton(isSaved: isSaved)
        let urlString = artifact.imageUrl!
        let url = URL(string: urlString) ?? URL(string: "unavailableImage")!
        self.artifactLabel.text = artifact.title
        
        imageClient.setImage(on: artifactImageView, fromURL: url, withPlaceholder: UIImage(systemName: "photo"))
    }
}
