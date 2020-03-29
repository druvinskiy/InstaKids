//
//  UITabBarControllerExtension.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/24/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

extension UITabBarController {
    static func createTabbar() -> UINavigationController {
        let tabbar = UITabBarController()
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.9334495664, green: 0.3899522722, blue: 0.2985906601, alpha: 1)
        
        let feedVC = createFeedVC(title: "Feed", image: #imageLiteral(resourceName: "FeedIcon"))
        let myDrawingsVC = createFeedVC(title: "My Drawings", image: #imageLiteral(resourceName: "UserIcon"))
        let settingsVC = createSettingsVC()
        let drawingVC = createDrawingVC()
        
        tabbar.viewControllers = [myDrawingsVC, drawingVC, feedVC, settingsVC]
        
        let navigationController = UINavigationController(rootViewController: tabbar)
        let backButton = UIBarButtonItem()

        backButton.title = "Back"
        navigationController.navigationBar.topItem?.backBarButtonItem = backButton
        
        return navigationController
    }
    
    private static func createDrawingVC() -> UIViewController {
        let drawingVC = UIViewController()
        drawingVC.view.backgroundColor = .white
        drawingVC.tabBarItem = UITabBarItem(title: "New Drawing", image: #imageLiteral(resourceName: "DrawingIcon"), selectedImage: nil)
        let navigationController = UINavigationController(rootViewController: drawingVC)
        //navigationController.modalPresentationStyle = .overFullScreen
        
        return drawingVC
    }
    
    private static func createSettingsVC() -> UINavigationController {
        let userVC = UsersListViewController()
        userVC.tabBarItem = UITabBarItem(title: "Settings", image: #imageLiteral(resourceName: "SettingsIcon"), selectedImage: nil)
        return UINavigationController(rootViewController: userVC)
    }
    
    private static func createFeedVC(title: String, image: UIImage) -> FeedViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let feedVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.feedViewController) as! FeedViewController
        feedVC.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: nil)
        
        return feedVC
    }
}
