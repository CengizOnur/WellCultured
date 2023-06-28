//
//  WllCLabel.swift
//  We II Cultured
//
//  Created by Onur Akdogan on 4.04.2022.
//

import UIKit

final class WllCLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(textAlignment: NSTextAlignment = .center, font: UIFont) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
        self.font = font
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .label
        font = UIFont.preferredFont(forTextStyle: .body)
        adjustsFontForContentSizeCategory = true
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.25
        lineBreakMode = .byTruncatingTail
        numberOfLines = 0
    }
}
