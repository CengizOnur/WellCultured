//
//  UIViewController+Extension.swift
//  We II Cultured
//
//  Created by Onur Akdogan on 22.02.2022.
//

import UIKit
import SafariServices

extension UIViewController {
    
    // MARK: - Alert
    
    func presentAlert(title: String, message: String, buttonTitle: String) {
        let alertVC = AlertsViewController(title: title, message: message, buttonTitle: buttonTitle)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        self.present(alertVC, animated: true)
    }
    
    
    // MARK: - Safari
    
    func presentSafariVC(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemRed
        present(safariVC, animated: true)
    }
}


//MARK: - Keyboard goes when tapping anywhere

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
