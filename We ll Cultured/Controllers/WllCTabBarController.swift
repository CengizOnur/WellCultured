//
//  WllCTabBarController.swift
//  We ll Cultured
//
//  Created by Onur Akdogan on 25.12.2022.
//

import Foundation
import UIKit

final class WllCTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .systemRed
        UINavigationBar.appearance().tintColor = .systemRed
        viewControllers = [createExhibitionNavigationController(), createInspiringNavigationController()]
    }
    
    
    func createExhibitionNavigationController() -> UINavigationController {
        let discoverVC = DiscoverViewController()
        discoverVC.tabBarItem = UITabBarItem(title: "Exhibition", image: UIImage(systemName: "text.below.photo"), tag: 0)
        
        let discoverNC = UINavigationController(rootViewController: discoverVC)
        discoverVC.navigationItem.title = "Exhibition"
        discoverVC.navigationItem.hidesBackButton = true
        
        return discoverNC
    }
    
    
    func createInspiringNavigationController() -> UINavigationController {
        let inspiringVC = InspiringViewController()
        inspiringVC.tabBarItem = UITabBarItem(title: "Inspiring", image: UIImage(systemName: "heart.fill"), tag: 1)
        
        let inspiringNC = UINavigationController(rootViewController: inspiringVC)
        inspiringVC.navigationItem.title = "Inspiring"
        inspiringVC.navigationItem.hidesSearchBarWhenScrolling = false
        
        return inspiringNC
    }
}
