//
//  AlertsViewController.swift
//  We II Cultured
//
//  Created by Onur Akdogan on 4.04.2022.
//

import UIKit

final class AlertsViewController: UIViewController {
    
    private var alertTitle: String?
    private var message: String?
    private var buttonTitle: String?
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    private lazy var titleLabel: WllCLabel = {
        let label = WllCLabel(textAlignment: .center, font: UIFont.systemFont(ofSize: 20, weight: .bold))
        label.text = alertTitle ?? "Something went wrong"
        return label
    }()
    
    private lazy var messageLabel: WllCLabel = {
        let label = WllCLabel(textAlignment: .center, font: UIFont.preferredFont(forTextStyle: .body))
        label.textColor = .secondaryLabel
        label.text = message ?? "Unable to complete request"
        label.numberOfLines = 4
        return label
    }()
    
    private lazy var actionButton: WllCButton = {
        let button = WllCButton(backgroundColor: .systemRed, title: buttonTitle ?? "Ok")
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let padding: CGFloat = 20
    
    
    init(title: String, message: String, buttonTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.buttonTitle = buttonTitle
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 240),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 32),
            
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            actionButton.heightAnchor.constraint(equalToConstant: 40),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -16),
        ])
    }
    
    
    private func setup() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        
        view.addSubview(containerView)
        view.addSubview(titleLabel)
        view.addSubview(actionButton)
        view.addSubview(messageLabel)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        activateConstraints()
    }
    
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
    
    
    // Deinit For Testing Purposes
    deinit {
        print("AlertsVC is deallocated")
    }
}
