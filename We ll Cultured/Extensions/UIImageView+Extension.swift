//
//  UIImageView+extension.swift
//  We II Cultured
//
//  Created by Onur Akdogan on 21.02.2022.
//

import Foundation
import UIKit

extension UIView {
    
    func showImageLoadingView() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        addSubview(containerView)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .systemRed
        
        // Set proper tag and alpha for UIView and UIImageView.
        containerView.setTagAndAlpha()
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.heightAnchor.constraint(equalTo: heightAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    
    func dismissImageLoadingView() {
        alpha = 1
        var containerViewInImageView = viewWithTag(50)
        var containerViewInView = viewWithTag(100)
        containerViewInImageView?.removeFromSuperview()
        containerViewInView?.removeFromSuperview()
        containerViewInImageView = nil
        containerViewInView = nil
    }
}


extension UIView {
    
    func setTagAndAlpha() {
        if superview is UIImageView {
            tag = 50
            alpha = 0.5
        } else {
            tag = 100
            alpha = 0
            UIView.animate(withDuration: 0.25) { self.alpha = 0.8 }
        }
    }
}
