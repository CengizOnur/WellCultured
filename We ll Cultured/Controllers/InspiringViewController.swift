//
//  InspiringViewController.swift
//  We II Cultured
//
//  Created by Onur Akdogan on 26.03.2022.
//

import UIKit

final class InspiringViewController: UIViewController {
    
    private var databaseManager: DatabaseService = DatabaseManager.shared
    
    private var artifacts = [ArtifactModel]()
    private var filteredArtifacts = [ArtifactModel]()
    
    private let searchController = UISearchController()
    private var isSearching = false
    
    private var initialSetupDone = false
    
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    private enum Section { case main }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, ArtifactModel?>!
    
    private let padding = 10.0
    
    private let verticalInset: CGFloat = 10
    private let horizontalInset: CGFloat = 10
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset)
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.register(ArtifactCell.self, forCellWithReuseIdentifier: ArtifactCell.reuseID)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    
    // MARK: - ConfigureUI
    
    private func flowLayout(collectionViewWidth: CGFloat, numberOfColumns: Int) {
        flowLayout.scrollDirection = .vertical
        let availableWidth = collectionViewWidth - 2 * horizontalInset - CGFloat((numberOfColumns - 1)) * flowLayout.minimumInteritemSpacing
        let width = floor(availableWidth / CGFloat(numberOfColumns))
        let height = width + padding
        let itemSize = CGSize(width: width, height: height)
        flowLayout.itemSize = itemSize
    }
    
    
    private func configureFlowLayout(safeAreaWidth: CGFloat) {
        if view.bounds.size.height > view.bounds.size.width {
            self.flowLayout(collectionViewWidth: safeAreaWidth, numberOfColumns: 3)
        } else {
            self.flowLayout(collectionViewWidth: safeAreaWidth, numberOfColumns: 4)
        }
    }
    
    
    private func setupConstraints() {
        sharedConstraints = [
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ]
    }
    
    
    private func setup() {
        view.backgroundColor = .systemBackground
        configureSearchController(searchController: searchController)
        view.addSubview(collectionView)
    }
    
    
    // MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configureDataSource()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let safeAreaWidth = self.view.safeAreaLayoutGuide.layoutFrame.width
        configureFlowLayout(safeAreaWidth: safeAreaWidth)
        if !initialSetupDone {
            initialSetupDone = true
            setupConstraints()
            NSLayoutConstraint.activate(sharedConstraints)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getInspiringArtifacts()
    }
    
    
    // MARK: - UIContextMenuConfiguration
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let delete = UIAction(
                title: "Remove",
                image: UIImage(systemName: "trash"),
                identifier: nil,
                discoverabilityTitle: nil,
                state: .off)
            { [weak self] _ in
                guard let self = self else { return }
                let currentArray = self.getCurrentArray()
                _ = self.databaseManager.removeArtifact(currentArray[indexPath.row])
                self.getInspiringArtifacts()
            }
            return UIMenu(
                title: "",
                image: UIImage(systemName: "photo"),
                identifier: nil,
                options: .displayInline,
                children: [delete])
        }
        return config
    }
    
    
    // MARK: - Database
    
    private func getInspiringArtifacts() {
        artifacts = databaseManager.queryArtifacts()
        updateSearchResults(for: searchController)
    }
    
    
    // MARK: - CollectionView
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ArtifactModel?>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, artifact) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtifactCell.reuseID, for: indexPath) as! ArtifactCell
            cell.set(artifact: artifact!)
            return cell
        })
    }
    
    
    private func updateData(in artifacts: [ArtifactModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ArtifactModel?>()
        snapshot.appendSections([.main])
        snapshot.appendItems(artifacts)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
    
    
    // MARK: - UISearchController
    
    private func configureSearchController(searchController: UISearchController) {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for inspiring artifacts"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        if #unavailable(iOS 15.0) {
            let item = searchController.searchBar.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        }
    }
}


// MARK: - UICollectionViewDelegate

extension InspiringViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentArray = getCurrentArray()
        let artifact = currentArray[indexPath.item]
        let imageVC = ImageViewController()
        imageVC.artifact = artifact
        let navController = UINavigationController(rootViewController: imageVC)
        
        let dissmisButton = UIBarButtonItem(
            title: "Done",
            image: nil,
            primaryAction: .init { [weak navController] _ in
                if #available(iOS 15.0, *) {
                    if let sheet = navController?.sheetPresentationController {
                        sheet.animateChanges {
                            navController?.dismiss(animated: true)
                        }
                    }
                } else {
                    navController?.dismiss(animated: true)
                }
            })
        
        dissmisButton.tintColor = .systemRed
        imageVC.navigationItem.rightBarButtonItem = dissmisButton
        if #available(iOS 15.0, *) {
            navController.sheetPresentationController?.prefersGrabberVisible = true
        }
        present(navController, animated: true)
    }
    
    
    private func getCurrentArray() -> [ArtifactModel] {
        return isSearching ? filteredArtifacts : artifacts
    }
}


// MARK: - UISearchResultsUpdating & UISearchBarDelegate

extension InspiringViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            isSearching = false
            updateData(in: artifacts)
            return
        }
        isSearching = true
        filteredArtifacts = artifacts.filter { $0.title.lowercased().contains(filter.lowercased()) }
        updateData(in: filteredArtifacts)
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(in: artifacts)
    }
}
