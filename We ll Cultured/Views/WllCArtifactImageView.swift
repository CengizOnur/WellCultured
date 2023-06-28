//
//  WllCArtifactImageView.swift
//  We II Cultured
//
//  Created by Onur Akdogan on 22.02.2022.
//

import UIKit

final class WllCArtifactImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
}
