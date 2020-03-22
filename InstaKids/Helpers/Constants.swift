//
//  Constants.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/18/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation

struct Constants {

    struct Storyboard {
        
        static let tabBarController = "MainTabBarController"
        static let loginNavController = "LoginNavController"
        static let feedSketchTableCellId = "SketchCell"
    }
    
    struct Segue {
        
        static let profileViewController = "goToCreateProfile"
    }
    
    struct localStorage {
        
        static let storedUsername = "storedUsername"
        static let storedUserId = "storedUserId"
    }
}
