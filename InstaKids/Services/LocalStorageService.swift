//
//  LocalStorageService.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/18/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation

class LocalStorageService {
    
    static func saveCurrentUser(user:SketchUser) {
        
        //Get standard user defaults
        let defaults = UserDefaults.standard
        
        defaults.setValue(user.userId, forKey: Constants.localStorage.storedUserId)
        defaults.setValue(user.username, forKey: Constants.localStorage.storedUsername)
        defaults.set(user.following, forKey: Constants.localStorage.storedFollowing)
    }
    
    static func loadCurrentUser() -> SketchUser? {
        
        //Get standard user defaults
        let defaults = UserDefaults.standard
        
        let userName = defaults.value(forKey: Constants.localStorage.storedUsername) as? String
        let userId = defaults.value(forKey: Constants.localStorage.storedUserId) as? String
        let following = defaults.value(forKey: Constants.localStorage.storedFollowing) as? [String]
        
        //Couldn't get a user, return nil
        guard userName != nil || userId != nil || following != nil else {
            return nil
        }
        
        //Return the user
        let u = SketchUser(userId: userId!, username: userName!, following: following)
        return u
    }
    
    static func clearCurrentUser() {
        
        //Get standard user defaults
        let defaults = UserDefaults.standard
        
        defaults.setValue(nil, forKey: Constants.localStorage.storedUserId)
        defaults.setValue(nil, forKey: Constants.localStorage.storedUsername)
    }
}
