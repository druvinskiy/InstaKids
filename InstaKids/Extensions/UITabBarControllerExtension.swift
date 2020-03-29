//
//  UITabBarControllerExtension.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/24/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

class IKTabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .systemGreen
        
        let feedVC = createFeedVC(title: "Feed", image: #imageLiteral(resourceName: "FeedIcon"))
        let myDrawingsVC = createFeedVC(title: "My Drawings", image: #imageLiteral(resourceName: "UserIcon"))
        let settingsVC = createSettingsVC()
        let drawingVC = createDrawingVC()
        
        viewControllers = [myDrawingsVC, drawingVC, feedVC, settingsVC]
    }
    
    func createDrawingVC() -> UIViewController {
        let drawingVC = UIViewController()
        drawingVC.view.backgroundColor = .white
        drawingVC.tabBarItem = UITabBarItem(title: "New Drawing", image: #imageLiteral(resourceName: "DrawingIcon"), selectedImage: nil)
        let navigationController = UINavigationController(rootViewController: drawingVC)
        //navigationController.modalPresentationStyle = .overFullScreen
        
        return drawingVC
    }
    
    func createSettingsVC() -> UINavigationController {
        let userVC = UsersListViewController()
        userVC.tabBarItem = UITabBarItem(title: "Settings", image: #imageLiteral(resourceName: "SettingsIcon"), selectedImage: nil)
        return UINavigationController(rootViewController: userVC)
    }
    
    func createFeedVC(title: String, image: UIImage) -> FeedViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let feedVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.feedViewController) as! FeedViewController
        feedVC.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: nil)
        
        return feedVC
    }
}
