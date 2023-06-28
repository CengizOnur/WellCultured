//
//  ExhibitionViewController.swift
//  We ll Cultured
//
//  Created by Onur Akdogan on 22.05.2022.
//

import UIKit

class ExhibitionViewController: UIViewController  {
    
    var networkClient: WellCulturedService = WellCulturedClient.shared
    var imageClient: ImageService = ImageClient.shared
    var databaseManager: DatabaseService = DatabaseManager.shared
    
    var exhibitModel: ExhibitModel? = nil
    var artifactModel: ArtifactModel? = nil
    
    var exhibitDataTask: URLSessionTaskProtocol?
    var artifactDataTask: URLSessionTaskProtocol?
    var artifactDataTasks: [URLSessionTaskProtocol] = []
    
    private var gotArtifactsCompletion: (() -> Void) = { }
    
    private let dispatchGroup = DispatchGroup()
    
    var objectIDs = [Int]()
    
    /// Images will be downloaded group by group.
    /// - Reasons:
    ///     - Better UX.
    ///     - According to the Museum API, there is a suggestion that 80 request per second rule.
    var groups: [Int : [Int]] = [:]
    
    private var artifactsTemp: [ArtifactModel] = []
    var artifacts = [ArtifactModel?]()
    var currentArtifactIndex = 0
    
    private var numberOfGroup = 0
    var currentGroup = 1
    
    /// To avoid passing a group in case of quick swiping to further groups.
    /// (It is not needed since there is activity indicator, but just in case.)
    var isGroupShownOnCollectionView = false
    
    /// Number of elements per group on collection view (custom paging)
    let maxNumberOfElementsInGroup = 18
    
    var query: String!
    
    let containerView = WllCContainerView(frame: .zero)
    
    enum Section { case main }
    var dataSource: UICollectionViewDiffableDataSource<Section, ArtifactModel?>!
    
    private var initialSetupDone = false
    
    private let verticalInset: CGFloat = 8
    private let horizontalInset: CGFloat = 8
    private let padding = 8.0
    
    private var sharedConstraints: [NSLayoutConstraint] = []
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset)
        return flowLayout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.register(ArtifactCell.self, forCellWithReuseIdentifier: ArtifactCell.reuseID)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    
    // MARK: - ConfigureUI
    
    private func configurePortraitFlowLayout(collectionViewWidth: CGFloat, collectionViewHeight: CGFloat) {
        flowLayout.scrollDirection = .horizontal
        let availableHeight = collectionViewHeight - 2 * verticalInset
        let height = availableHeight
        let width = height - 8
        let itemSize = CGSize(width: floor(width), height: floor(height))
        flowLayout.itemSize = itemSize
    }
    
    
    private func configureLandscapeFlowLayout(collectionViewWidth: CGFloat, collectionViewHeight: CGFloat) {
        flowLayout.scrollDirection = .vertical
        let availableWidth = collectionViewWidth - 2 * horizontalInset - 2 * flowLayout.minimumInteritemSpacing
        let width = availableWidth / 3
        let height = width + padding
        let itemSize = CGSize(width: floor(width), height: floor(height))
        flowLayout.itemSize = itemSize
    }
    
    
    private func setupConstraints() {
        sharedConstraints = [
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
        ]
        
        portraitConstraints = [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: (view.safeAreaLayoutGuide.layoutFrame.size.height) / 5),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            containerView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -padding),
        ]
        
        landscapeConstraints = [
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            collectionView.widthAnchor.constraint(equalToConstant: (view.safeAreaLayoutGuide.layoutFrame.size.width) / 2),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: -padding),
        ]
    }
    
    
    private func invalidateOldConstraints() {
        if sharedConstraints.count > 0 && sharedConstraints[0].isActive {
            NSLayoutConstraint.deactivate(sharedConstraints)
        }
        if portraitConstraints.count > 0 && portraitConstraints[0].isActive {
            NSLayoutConstraint.deactivate(portraitConstraints)
        }
        if landscapeConstraints.count > 0 && landscapeConstraints[0].isActive {
            NSLayoutConstraint.deactivate(landscapeConstraints)
        }
    }
    
    
    private func activateConstraints() {
        setupConstraints()
        NSLayoutConstraint.activate(sharedConstraints)
        if view.safeAreaLayoutGuide.layoutFrame.size.height > view.safeAreaLayoutGuide.layoutFrame.size.width {
            NSLayoutConstraint.activate(portraitConstraints)
            configurePortraitFlowLayout(collectionViewWidth: view.safeAreaLayoutGuide.layoutFrame.size.width - padding * 2, collectionViewHeight: view.safeAreaLayoutGuide.layoutFrame.size.height / 5)
        } else {
            NSLayoutConstraint.activate(landscapeConstraints)
            configureLandscapeFlowLayout(collectionViewWidth: view.safeAreaLayoutGuide.layoutFrame.size.width / 2, collectionViewHeight: view.safeAreaLayoutGuide.layoutFrame.size.height - padding * 2)
        }
    }
    
    
    private func setup() {
        view.addSubview(containerView)
        view.addSubview(collectionView)
        
        // CollectionView settings
        collectionView.contentInsetAdjustmentBehavior = .never
        
        // Style
        view.backgroundColor = .systemBackground
        
        // Adding targets
        containerView.inspiringButton.addTarget(self, action: #selector(changeSavedStatus), for: .touchUpInside)
        containerView.detailButton.addTarget(self, action: #selector(goForDetails), for: .touchUpInside)
        
        // Swiping settings
        let swipeGestureRecognizerNext = UISwipeGestureRecognizer(target: self, action: #selector(goToNext(_:)))
        let swipeGestureRecognizerPrevious = UISwipeGestureRecognizer(target: self, action: #selector(goToPrevious(_:)))
        swipeGestureRecognizerNext.direction = .left
        swipeGestureRecognizerPrevious.direction = .right
        containerView.artifactImageView.isUserInteractionEnabled = true
        containerView.artifactImageView.addGestureRecognizer(swipeGestureRecognizerNext)
        containerView.artifactImageView.addGestureRecognizer(swipeGestureRecognizerPrevious)
    }
    
    
    // MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configureDataSource()
        if let query = query {
            getExhibit(about: query)
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !initialSetupDone {
            initialSetupDone = true
            activateConstraints()
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard size != view.bounds.size else { return }
        invalidateOldConstraints()
        collectionView.collectionViewLayout.invalidateLayout()
        coordinator.animate { [weak self] context in
            guard let self = self else { return }
            let safeAreaSize = self.view.safeAreaLayoutGuide.layoutFrame.size
            self.activateConstraints()
            self.scrollToItem(size: safeAreaSize)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        if initialSetupDone {
            invalidateOldConstraints()
            activateConstraints()
            scrollToItem(size: view.safeAreaLayoutGuide.layoutFrame.size)
        }
        
        updateDatabase()
        if !artifacts.isEmpty {
            let artifact = artifacts[currentArtifactIndex]!
            updateInspiringButton(isSaved: databaseManager.checkArtifactIsSaved(artifact))
        }
    }
    
    
    // MARK: - Networking
    
    func getExhibit(about query: String) {
        guard exhibitDataTask == nil else { return }
        view.showImageLoadingView()
        
        // Since WellCulturedClient.shared is used, there is no need to wrap the modification with an asynchronous dispatch call to the main thread. It is already handled in helper function in WellCulturedClient by setting parameter responseQueue to .main within WellCulturedClient.shared.
        exhibitDataTask = networkClient.getExhibit(about: query) { [weak self] result in
            guard let self = self else { return }
            self.exhibitDataTask = nil
            
            switch result {
            case .success(let exhibit):
                self.adjustExhibit(exhibit: exhibit)
                self.getArtifacts(in: self.groups, which: self.currentGroup)
            case .failure(let error):
                self.exhibitModel = nil
                self.presentAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    func getArtifacts(in groups: [Int : [Int]], which group: Int) {
        for objectID in groups[group]! {
            dispatchGroup.enter()
            getArtifact(with: objectID) { [weak self] exhibit in
                guard let self = self else { return }
                self.artifactsTemp.append(exhibit)
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {  [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { self.view.dismissImageLoadingView() }
            self.artifactDataTask = nil
            self.artifactDataTasks = []
            
            self.collectionView.backgroundColor = .systemGray6
            self.containerView.detailButton.updateButton(with: UIImage(systemName: "network"), tintColor: .systemGray)
            self.containerView.artifactImageView.layer.borderColor = UIColor.systemGray5.cgColor
            
            self.artifacts += self.artifactsTemp
            self.updateData()
            self.isGroupShownOnCollectionView = true
            
            if !self.artifactsTemp.isEmpty && self.currentGroup == 1 {
                self.showImage(from: self.artifactsTemp[0])
            }
            
            self.artifactsTemp = []
            
            // For testing purposes
            self.gotArtifactsInGroup()
        }
    }
    
    
    func getArtifact(with objectID: Int, completed: @escaping (ArtifactModel) -> Void) {
        guard artifactDataTasks.count < groups[currentGroup]!.count else { return }
        
        // Since WellCulturedClient.shared is used, there is no need to wrap the modification with an asynchronous dispatch call to the main thread. It is already handled in helper function in WellCulturedClient by setting parameter responseQueue to .main within WellCulturedClient.shared.
        artifactDataTask = networkClient.getArtifact(with: objectID, completion: { [weak self] result in
            guard let self = self else { return }
            defer { self.dispatchGroup.leave() }
            
            switch result {
            case .success(let artifact):
                let artifactModel = ArtifactModel(artifactData: artifact)
                self.artifactModel = artifactModel
                completed(artifactModel)
            case .failure(_):
                self.artifactModel = nil
            }
        })
        artifactDataTasks.append(artifactDataTask!)
    }
    
    
    // For testing purposes
    private func gotArtifactsInGroup() {
        gotArtifactsCompletion()
    }
    
    
    // For testing purposes
    func gotArtifacts(completed: @escaping () -> Void) {
        gotArtifactsCompletion = completed
    }
    
    
    func showImage(from artifact: ArtifactModel?) {
        containerView.showImage(from: artifact, imageClient: imageClient, databaseManager: databaseManager)
    }
    
    
    // MARK: - To next and previous
    
    private func goToNextGroup() {
        guard currentGroup != numberOfGroup, isGroupShownOnCollectionView else { return }
        currentGroup += 1
        isGroupShownOnCollectionView = false
        setCellColor(color: .systemGray6)
        getArtifacts(in: groups, which: currentGroup)
        setCellColor(color: .systemGray4)
    }
    
    
    func goToNextArtifact() {
        setCellColor(color: .systemGray6)
        if currentArtifactIndex < artifacts.count - 1 {
            currentArtifactIndex += 1
            showImage(from: artifacts[currentArtifactIndex])
        } else {
            guard currentGroup != numberOfGroup else {
                setCellColor(color: .systemGray4)
                return
            }
            goToNextGroup()
        }
        setCellColor(color: .systemGray4)
    }
    
    
    func goToPreviousArtifact() {
        setCellColor(color: .systemGray6)
        currentArtifactIndex -= 1
        if currentArtifactIndex >= 0 {
            showImage(from: artifacts[currentArtifactIndex])
        } else {
            currentArtifactIndex = 0
        }
        setCellColor(color: .systemGray4)
    }
    
    
    @objc private func goToNext(_ sender: UISwipeGestureRecognizer) {
        goToNextArtifact()
    }
    
    
    @objc private func goToPrevious(_ sender: UISwipeGestureRecognizer) {
        goToPreviousArtifact()
    }
    
    
    // MARK: - CollectionView
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ArtifactModel?>(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, artifact) -> UICollectionViewCell in
            guard let self = self else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtifactCell.reuseID, for: indexPath) as! ArtifactCell
            cell.set(artifact: artifact!)
            if indexPath.row == self.currentArtifactIndex {
                cell.backgroundColor = .systemGray4
            } else {
                cell.backgroundColor = .systemGray6
            }
            return cell
        })
    }
    
    
    private func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ArtifactModel?>()
        snapshot.appendSections([.main])
        snapshot.appendItems(artifacts)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
    
    
    private func setCellColor(color: UIColor) {
        if let cell = collectionView.cellForItem(at: IndexPath(row: currentArtifactIndex, section: 0)) as? ArtifactCell {
            cell.backgroundColor = color
        }
    }
    
    
    private func scrollToItem(size: CGSize) {
        guard !artifacts.isEmpty else { return }
        if size.height > size.width {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: IndexPath(item: currentArtifactIndex, section: 0), at: .centeredHorizontally, animated: true)
        } else {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: IndexPath(item: currentArtifactIndex, section: 0), at: .centeredVertically, animated: true)
        }
    }
    
    
    // MARK: - Safari
    
    @objc func goForDetails() {
        let url = URL(string: artifacts[currentArtifactIndex]?.linkToWebsite ?? "www.google.com")
        if let url = url { presentSafariVC(with: url) }
    }
    
    
    // MARK: - Inspiring
    
    @objc private func changeSavedStatus() {
        let artifact = artifacts[currentArtifactIndex]!
        let isSaved = databaseManager.checkArtifactIsSaved(artifact)
        if isSaved {
            removeArtifact()
        } else {
            saveArtifact(artifact)
        }
        updateInspiringButton(isSaved: !isSaved)
        updateDatabase()
    }
    
    
    private func removeArtifact() {
        let artifact = artifacts[currentArtifactIndex]!
        let isSuccesfullyRemoved = databaseManager.removeArtifact(artifact)
        if !isSuccesfullyRemoved { presentAlert(title: "Removing from Inspirings", message: "Something went wrong while removing", buttonTitle: "Ok") }
    }
    
    
    private func saveArtifact(_ artifact: ArtifactModel) {
        let isSuccesfullySaved = databaseManager.saveArtifact(artifact)
        if !isSuccesfullySaved { presentAlert(title: "Adding to Inspirings", message: "Something went wrong while adding", buttonTitle: "Ok") }
    }
    
    
    private func updateInspiringButton(isSaved: Bool) {
        containerView.updateInspiringButton(isSaved: isSaved)
    }
    
    
    private func updateDatabase() {
        _ = databaseManager.queryArtifacts()
    }
    
    
    // Deinit For Testing Purposes
    deinit {
        print("ExhibitionVC is deallocated")
    }
}


// MARK: - UICollectionViewDelegate

extension ExhibitionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let preloadingTreashold = Int(artifacts.count * 3/4)
        let threasholdReached = indexPath.item >= preloadingTreashold
        if threasholdReached {
            goToNextGroup()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setCellColor(color: .systemGray6)
        currentArtifactIndex = indexPath.row
        setCellColor(color: .systemGray4)
        showImage(from: artifacts[currentArtifactIndex])
    }
}


// MARK: - Helper Functions

extension ExhibitionViewController {
    
    private func adjustExhibit(exhibit: ExhibitData) {
        exhibitModel = ExhibitModel(exhibitData: exhibit)
        objectIDs = exhibitModel?.objectIDs ?? []
        numberOfGroup = determineNumberOfGroups(objectsIDs: self.objectIDs, maxNumberOfElementsInGroup: maxNumberOfElementsInGroup)
        distributeObjectsToGroups(objectsIDs: objectIDs, numberOfGroups: self.numberOfGroup, maxNumberOfElementsInGroup: maxNumberOfElementsInGroup)
    }
    
    
    private func determineNumberOfGroups(objectsIDs: [Int], maxNumberOfElementsInGroup: Int) -> Int {
        if objectsIDs.count % maxNumberOfElementsInGroup == 0 {
            return objectsIDs.count / maxNumberOfElementsInGroup
        } else {
            return objectsIDs.count / maxNumberOfElementsInGroup + 1
        }
    }
    
    
    private func distributeObjectsToGroups(objectsIDs: [Int], numberOfGroups: Int, maxNumberOfElementsInGroup: Int) {
        for i in 1...numberOfGroups {
            self.groups[i] = []
            var indexOfLastElementInGroup = i * maxNumberOfElementsInGroup - 1
            if indexOfLastElementInGroup >= objectsIDs.count {
                indexOfLastElementInGroup = objectsIDs.count - 1
            }
            for j in (i-1) * maxNumberOfElementsInGroup...indexOfLastElementInGroup {
                self.groups[i]!.append(objectsIDs[j])
            }
        }
    }
}
