//
//  WllCButton.swift
//  We II Cultured
//
//  Created by Onur Akdogan on 23.03.2022.
//

import UIKit

final class WllCButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(backgroundColor: UIColor, title: String) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.setTitle(title, for: .normal)
    }
    
    
    convenience init(backgroundColor: UIColor, title: String?, image: UIImage?, imageSize: CGFloat = 24) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.setTitle(title, for: .normal)
        self.updateButton(with: image, tintColor: .white, imageSize: imageSize)
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 20
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
    }
    
    
    func updateButton(with newImage: UIImage?, tintColor: UIColor, imageSize: CGFloat = 24) {
        let imageFont = UIFont.systemFont(ofSize: imageSize)
        let configuration = UIImage.SymbolConfiguration(font: imageFont)
        let image = newImage?.withConfiguration(configuration)
        setImage(image, for: .normal)
        self.tintColor = tintColor
    }
}
