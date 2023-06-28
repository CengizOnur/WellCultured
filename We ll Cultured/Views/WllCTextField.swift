//
//  WllCTextField.swift
//  We II Cultured
//
//  Created by Onur Akdogan on 24.02.2022.
//

import UIKit

final class WllCTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        returnKeyType = .search
        layer.borderColor = UIColor.systemGray4.cgColor
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        leftViewMode = .always
        autocapitalizationType = .none
        textColor = .label
        tintColor = .label
        textAlignment = .center
        font = UIFont.preferredFont(forTextStyle: .title2)
        adjustsFontSizeToFitWidth = true
        minimumFontSize = 12
        backgroundColor = .tertiarySystemBackground
        autocorrectionType = .no
        borderStyle = .roundedRect
        placeholder = "Type anything about you wonder..."
        
        if #unavailable(iOS 15.0) {
            let item = self.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        }
    }
}
