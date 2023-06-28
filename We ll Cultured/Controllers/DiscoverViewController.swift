//
//  DiscoverViewController.swift
//  We II Cultured
//
//  Created by Onur Akdogan on 21.01.2021.
//

import UIKit
import RealmSwift

final class DiscoverViewController: UIViewController {
    
    private var initialSetupDone = false
    
    private let label: WllCLabel = {
        let label = WllCLabel(font: UIFont(name: "Baskerville", size: 40)!)
        label.text = "Discover and be well cultured."
        return label
    }()
    
    lazy var searchField: WllCTextField = {
        let textField = WllCTextField()
        textField.delegate = self
        return textField
    }()
    
    private lazy var searchButton: WllCButton = {
        let button = WllCButton(backgroundColor: .systemRed, title: nil, image: UIImage(systemName: "magnifyingglass"), imageSize: 20)
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let padding = 8.0
    
    
    // MARK: - ConfigureUI
    
    private func activateConstraints() {
        let searchFieldCenterYConstraint = searchField.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        if #available(iOS 15.0, *) {
            searchFieldCenterYConstraint.priority = .defaultHigh
        }
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: searchField.topAnchor, constant: padding * -5),
            
            searchFieldCenterYConstraint,
            searchField.leadingAnchor.constraint(equalToSystemSpacingAfter: label.leadingAnchor, multiplier: 2),
            searchField.heightAnchor.constraint(equalToConstant: padding * 5),
            
            searchButton.leadingAnchor.constraint(equalToSystemSpacingAfter: searchField.trailingAnchor, multiplier: 1),
            searchButton.widthAnchor.constraint(equalToConstant: padding * 5),
            searchButton.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: padding * -2),
            searchButton.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            searchButton.heightAnchor.constraint(equalToConstant: padding * 5),
        ])
    }
    
    
    private func setup() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(label)
        view.addSubview(searchField)
        view.addSubview(searchButton)
        
        // keyboard
        self.hideKeyboardWhenTappedAround()
        if #available(iOS 15.0, *) {
            searchField.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -8).isActive = true
        }
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
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchField.text = ""
        searchField.placeholder = "Type any word to discover..."
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        navigationItem.compactAppearance = navigationBarAppearance
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #unavailable(iOS 15.0) {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if #unavailable(iOS 15.0) {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    
    // MARK: - Push ExhibitionVC
    
    @objc func searchButtonTapped() {
        pushExhibitionVC()
    }
    
    
    @objc func pushExhibitionVC() {
        if let text = searchField.text {
            guard text != "" else {
                searchField.placeholder = "Type something"
                return
            }
        }
        dismissKeyboard()
        let exhibitionVC = ExhibitionViewController()
        exhibitionVC.query = searchField.text
        exhibitionVC.title = searchField.text?.capitalized
        navigationController?.pushViewController(exhibitionVC, animated: true)
    }
}


// MARK: - UITextFieldDelegate

extension DiscoverViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchField {
            pushExhibitionVC()
        }
        return true
    }
}


// MARK: - Keyboard

extension DiscoverViewController {
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedSearchFieldFrame = view.convert(searchField.frame, from: searchField.superview)
        let searchFieldBottomY = convertedSearchFieldFrame.origin.y + convertedSearchFieldFrame.size.height
        
        // if searchFields bottom is beneath keyboards bottom, frame goes up
        if searchFieldBottomY > keyboardTopY {
            let preNewFrameY = -(searchFieldBottomY - keyboardTopY) - 8
            /// - When keyboardWillShow is called more than two times (natural behaviour, not about absence of removing observer etc.):
            /// If decision was to center searchField respect to view, not respect to safeArea, it would be fine,
            /// but instead, it is using safeArea to center searchField, so changing height of safeArea should be observed.
            ///
            /// Instead of counting of calling keyboardWillShow (which was another solution), the decision is observing of changing safeAreaSize and taking action respectively.
            ///
            /// When frame goes up, safeAreaInsets.bottom will be 0.
            if #available(iOS 11.0, *) {
                calculateWithSafeBottom(bottom: view.safeAreaInsets.bottom, preNewFrameY: preNewFrameY)
            } else {
                calculateWithSafeBottom(bottom: bottomLayoutGuide.length, preNewFrameY: preNewFrameY)
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    
    func calculateWithSafeBottom(bottom: CGFloat, preNewFrameY: CGFloat) {
        if bottom > 0 {
            let newFrameY = preNewFrameY - bottom / 2
            view.frame.origin.y = newFrameY
        } else {
            view.frame.origin.y = preNewFrameY
        }
    }
}
