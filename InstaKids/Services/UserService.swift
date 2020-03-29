//
//  UserService.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/18/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UserService {
    
    static func getUsers(completion: @escaping ([SketchUser]) -> Void) -> Void {
        
        let dbRef = Database.database().reference()
        
//        dbRef.queryOrdered(byChild: "following")
//            .queryEqual(toValue: true)
//            .observeSingleEvent(of: .value) { (snapshot) in
//                <#code#>
//        }
        
        
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
    
    static func createUserProfile(userId: String, username: String, profileImage: UIImage, completion: @escaping (SketchUser?) -> Void) {
        
        //Get data representation of the image
        let photoData = profileImage.jpegData(compressionQuality: 0.1)
        
        guard photoData != nil else {
            print("Couldn't turn the image into data")
            return
        }
        
        //Get a storage reference
        let filename = UUID().uuidString
        
        let ref = Storage.storage().reference().child("profileImages/\(userId)/\(filename).jpg")
        
        //Upload the photo
        ref.putData(photoData!, metadata: nil) { (metadata, error) in
            
            if error != nil {
                //An error during upload occured
            }
            else {
                //Upload was successfull, now create a database entry
                createUserDatabaseEntry(ref: ref, userId: userId, username: username) { (user) in
                    completion(user)
                }
            }
        }
    }
    
    private static func createUserDatabaseEntry(ref: StorageReference, userId: String, username: String, completion: @escaping (SketchUser?) -> Void) {
        
        //Get a download url for the photo
        ref.downloadURL { (url, error) in
            
            if error != nil {
                //Couldn't retrieve the url
                return
            } else {
                //Create a dictionary for the user profile
                let userProfileData = ["username":username, "profileImageUrl" : url!.absoluteString]
                
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
    
    static func follow(_ followUserId: String) {
        let currentUserid = Auth.auth().currentUser!.uid
        
        let dbRef = Database.database().reference().child("users").child(currentUserid).child("following")
        
        let data = [followUserId : true]
        
        dbRef.updateChildValues(data)
    }
}
