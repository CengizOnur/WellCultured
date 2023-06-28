//
//  ImageViewController.swift
//  We II Cultured
//
//  Created by Onur Akdogan on 21.01.2021.
//

import UIKit

final class ImageViewController: UIViewController {
    
    var artifact: ArtifactModel!
    private var imageClient: ImageService = ImageClient.shared
    private var databaseManager: DatabaseService = DatabaseManager.shared
    
    private let containerView = WllCContainerView(frame: .zero)
    private var initialSetupDone = false
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    private let padding = 8.0
    
    
    // MARK: - ConfigureUI
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding * 5),
        ])
    }
    
    
    private func setup() {
        view.addSubview(containerView)
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        containerView.detailButton.addTarget(self, action: #selector(goForDetails), for: .touchUpInside)
        containerView.inspiringButton.addTarget(self, action: #selector(changeSavedStatus), for: .touchUpInside)
        containerView.detailButton.updateButton(with: UIImage(systemName: "network"), tintColor: .systemGray)
        containerView.artifactImageView.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    
    // MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !initialSetupDone {
            initialSetupDone = true
            activateConstraints()
            showImage(from: artifact)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentingViewController?.viewWillDisappear(true)
        
        // Add grabber if the version is older than iOS 15.0
        if #unavailable(iOS 15.0) {
            addGrabber()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.viewWillAppear(true)
    }
    
    
    // MARK: - Networking
    
    private func showImage(from artifact: ArtifactModel?) {
        containerView.showImage(from: artifact, imageClient: imageClient, databaseManager: databaseManager)
    }
    
    
    // MARK: - Safari
    
    @objc private func goForDetails() {
        let url = URL(string: artifact.linkToWebsite)
        if let url = url {
            presentSafariVC(with: url)
        }
    }
    
    
    // MARK: - Inspiring
    
    @objc private func changeSavedStatus() {
        let isSaved = databaseManager.checkArtifactIsSaved(artifact)
        if isSaved {
            removeArtifact()
        } else {
            saveArtifact(artifact)
        }
        updateSavedButton(isSaved: !isSaved)
        updateDatabase()
    }
    
    
    private func removeArtifact() {
        let isSuccesfullyRemoved = databaseManager.removeArtifact(artifact)
        if !isSuccesfullyRemoved { presentAlert(title: "Removing", message: "Something went wrong while removing", buttonTitle: "Ok") }
    }
    
    
    private func saveArtifact(_ artifact: ArtifactModel) {
        let isSuccesfullySaved = databaseManager.saveArtifact(artifact)
        if !isSuccesfullySaved { presentAlert(title: "Saving", message: "Something went wrong while saving", buttonTitle: "Ok") }
    }
    
    
    private func updateSavedButton(isSaved: Bool) {
        containerView.updateInspiringButton(isSaved: isSaved)
    }
    
    
    private func updateDatabase() {
        _ = databaseManager.queryArtifacts()
    }
    
    
    // MARK: - Adding grabber if the version is older than iOS 15
    
    private func addGrabber() {
        let grabber = UIView()
        grabber.translatesAutoresizingMaskIntoConstraints = false
        grabber.backgroundColor = .tertiaryLabel
        let grabberSize = CGSize(width: 30, height: 5)
        grabber.frame = CGRect(origin: CGPoint(x: (view.frame.width - grabberSize.width) / 2, y: 8), size: grabberSize)
        grabber.layer.cornerRadius = grabberSize.height / 2
        navigationController?.navigationBar.addSubview(grabber)
    }
    
    
    // Deinit For Testing Purposes
    deinit {
        print("ImageVC is deallocated")
    }
}
