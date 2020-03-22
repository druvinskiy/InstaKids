//
//  UserService.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/18/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserService {
    
    static func getUsers(completion: @escaping ([SketchUser]) -> Void) -> Void {
        
        let dbRef = Database.database().reference()
        
        dbRef.child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            var retrievedUsers = [SketchUser]()
            
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            
            if let snapshots = snapshots {
                
                for snap in snapshots {
                    
                    let user = SketchUser(snapshot: snap)
                    
                    if user != nil {
                        retrievedUsers.insert(user!, at: 0)
                    }
                }
            }
            
            completion(retrievedUsers)
        }
    }
    
    static func createUserProfile(userId: String, username: String, completion: @escaping (SketchUser?) -> Void) -> Void {
        
        //Create a dictionary for the user profile
        let userProfileData = ["username":username]
        
        //Get a dadabase reference
        let ref = Database.database().reference()
        
        //Create the profile for the userid
        ref.child("users").child(userId).setValue(userProfileData) { (error, ref) in
            
            if error != nil {
                //There was an error
                completion(nil)
            }
            else {
                //Create a user and pass it back
                let u = SketchUser(userId: userId, username: username)
                completion(u)
            }
        }
    }
    
    static func getUserProfile(userId: String, completion: @escaping (SketchUser?) -> Void) -> Void {
        
        //Get a database reference
        let ref = Database.database().reference()
        
        //Try to retrieve the profile for the passed in userid
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            
            let user = SketchUser(snapshot: snapshot)
            
            if user != nil {
                completion(user!)
            } else {
                completion(nil)
            }
        }
    }
}
