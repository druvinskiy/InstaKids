//
//  IKTabBarController.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/24/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

enum ItemTitle: String {
    case myDrawings = "My Drawings"
    case newDrawing = "New Drawing"
    case feed = "Feed"
    case follow = "Follow"
}

class IKTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = Theme.mainColor
        
        let feedVC = createFeedVC(title: ItemTitle.feed.rawValue, image: #imageLiteral(resourceName: "FeedIcon"))
        let myDrawingsVC = createFeedVC(title: ItemTitle.myDrawings.rawValue, image: #imageLiteral(resourceName: "UserIcon"))
        let settingsVC = createSettingsVC()
        let drawingVC = createDrawingVC()
        
        viewControllers = [myDrawingsVC, drawingVC, feedVC, settingsVC]
    }
    
    func createDrawingVC() -> UINavigationController {
        let drawingVCHelper = UIViewController()
        drawingVCHelper.view.backgroundColor = .white
        drawingVCHelper.tabBarItem = UITabBarItem(title: ItemTitle.newDrawing.rawValue, image: #imageLiteral(resourceName: "DrawingIcon"), selectedImage: nil)
        let navigationController = UINavigationController(rootViewController: drawingVCHelper)
        configure(navigationController)
        //navigationController.modalPresentationStyle = .overFullScreen
        
        return navigationController
    }
    
    func createSettingsVC() -> UINavigationController {
        let userVC = UsersListViewController()
        userVC.tabBarItem = UITabBarItem(title: ItemTitle.follow.rawValue, image: #imageLiteral(resourceName: "FollowIcon"), selectedImage: nil)
        
        let navigationController = UINavigationController(rootViewController: userVC)
        configure(navigationController)
        
        return navigationController
    }
    
    func createFeedVC(title: String, image: UIImage) -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let feedVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.feedViewController) as! FeedViewController
        feedVC.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: nil)
        
        let navigationController = UINavigationController(rootViewController: feedVC)
        navigationController.navigationBar.prefersLargeTitles = true
        configure(navigationController)
        
        return navigationController
    }
    
    func configure(_ navigationController: UINavigationController) {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = Theme.mainColor
            navigationController.navigationBar.standardAppearance = navBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
}
