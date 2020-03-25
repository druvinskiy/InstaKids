//
//  UITabBarControllerExtension.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/24/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

extension UITabBarController {
    static func createTabbar() -> UITabBarController {
        let tabbar = UITabBarController()
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.9334495664, green: 0.3899522722, blue: 0.2985906601, alpha: 1)
        
        let feedVC = createFeedVC(title: "Feed", image: #imageLiteral(resourceName: "FeedIcon"), tag: 0)
        let myDrawingsVC = createFeedVC(title: "My Drawings", image: #imageLiteral(resourceName: "CrayonIcon"), tag: 1)
        
        let userVC = UsersListViewController()
        userVC.tabBarItem = UITabBarItem(title: "Users", image: #imageLiteral(resourceName: "UserIcon"), tag: 2)
        
        tabbar.viewControllers = [feedVC, myDrawingsVC, userVC]
        
        return tabbar
    }
    
    private static func createFeedVC(title: String, image: UIImage, tag: Int) -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let feedVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.feedViewController)
        feedVC.tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
        
        return UINavigationController(rootViewController: feedVC)
    }
}
