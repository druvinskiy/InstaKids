//
//  SketchService.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/18/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import UIKit
import PencilKit

class SketchService {
    
    static func getSketches(completion: @escaping ([Sketch]) -> Void) -> Void {
        
        //Getting a reference to the database
        let dbRef = Database.database().reference()
        
        //Make the db call
        dbRef.child("sketches").observeSingleEvent(of: .value) { (snapshot) in
            
            //Declare an array to hold the photos
            var retrievedSketches = [Sketch]()
            
            //Get the list of snapshots
            let snapshots = snapshot.children.allObjects as? [DataSnapshot]
            
            if let snapshots = snapshots {
                
                for snap in snapshots {
                    
                    //Try to create a photo from a snapshot
                    let p =  Sketch(snapshot: snap)
                    
                    //If successful, then add it to our array
                    if p != nil {
                        retrievedSketches.insert(p!, at: 0)
                    }
                }
            }
            
            //After parsing the snapshots, call the completion closure
            completion(retrievedSketches)
        }
    }
    
    static func saveSketch(drawing: PKDrawing, thumbnailImage: UIImage) {
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(drawing)
            
            let photoData = thumbnailImage.jpegData(compressionQuality: 0.1)
            
            guard photoData != nil else {
                print("Couldn't turn the image into data")
                return
            }
            
            //Get a storage reference
            let userid = Auth.auth().currentUser!.uid
            let filename = UUID().uuidString
            
            let storage = Storage.storage()
            let drawingRef = storage.reference().child("drawings/\(userid)/\(filename)")
            let imageRef = storage.reference().child("images/\(userid)/\(filename).jpg")
                        
            //Upload the sketch
            drawingRef.putData(encoded, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    //An error during upload occured
                }
                else {
                    //Upload was successfull, now create a database entry
                    //self.createSketchDatabaseEntry(ref: drawingRef)
                }
            }
            
            imageRef.putData(encoded, metadata: nil) { (metdata, error) in
                if error != nil {
                    //An error during upload occured
                }
                else {
                    //Upload was successfull, now create a database entry
                    self.createSketchDatabaseEntry(ref: imageRef)
                }
            }
        
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private static func createSketchDatabaseEntry(ref: StorageReference) {
        
        //Get a download url for the photo
        ref.downloadURL { (url, error) in
            
            if error != nil {
                //Couldn't retrieve the url
                return
            } else {
                
                //Get the meta data for the db entry
                
                //User
                let user = LocalStorageService.loadCurrentUser()
                
                guard user != nil else {
                    return
                }
                
                //Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .full
                
                let dateString = dateFormatter.string(from: Date())
                
                //Create sketch data
                let photoData = ["byId": user!.userId!, "byUsername": user!.usermname!, "date": dateString, "imageUrl": url!.absoluteString]
                
                //Write a database entry
                let dbRef = Database.database().reference().child("sketches").childByAutoId()
                dbRef.setValue(photoData, withCompletionBlock: { (error, dbRef) in
                    
                    if error != nil {
                        //There was an error in witing the database entry
                        return
                    }
                    else {
                        //Database entry for the photo was written
                    }
                })
            }
        }
    }
    
    static func downloadImage(from urlString: String, completion: @escaping (UIImage) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            //guard let self = self else { return }
            if error != nil { return }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return }
            guard let data = data else { return }
            
            guard let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        task.resume()
    }
}
