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
    
    static func saveSketch(drawing: PKDrawing, thumbnailImage: UIImage, sketchId: String?, completion: @escaping (Sketch) -> Void) {
        
        do {
            //let encoder = JSONEncoder()
            let drawingData = drawing.dataRepresentation()
            
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
            drawingRef.putData(drawingData, metadata: nil) { (metadata, error) in
                
                guard error == nil else { return }
                
                imageRef.putData(photoData!, metadata: nil) { (metdata, error) in
                    
                    guard error == nil else { return }
                    
                    createSketchDatabaseEntry(drawingRef: drawingRef, imageRef: imageRef, sketchId: sketchId) { (sketch) in
                        completion(sketch)
                    }
                }
            }
            
        }
    }
    
    private static func createSketchDatabaseEntry(drawingRef: StorageReference, imageRef: StorageReference, sketchId: String?, completion: @escaping (Sketch) -> Void) {
        
        //Get a download url for the photo
        drawingRef.downloadURL { (drawingUrl, error) in
            
            guard error == nil else { return }
            
            imageRef.downloadURL { (imageUrl, error) in
                guard error == nil else { return }
                
                //Get the meta data for the db entry
                
                //User
                let user = LocalStorageService.loadCurrentUser()
                
                guard user != nil else { return }
                
                //Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .full
                
                let dateString = dateFormatter.string(from: Date())
                
                //Create sketch data
                let photoData = ["byId": user!.userId!, "byUsername": user!.usermname!, "date": dateString, "drawingUrl" : drawingUrl!.absoluteString, "imageUrl" : imageUrl!.absoluteString]
                
                let root = "sketches"
                let dbRef: DatabaseReference
                
                if sketchId != nil {
                    dbRef = Database.database().reference().child(root).child(sketchId!)
                } else {
                    dbRef = Database.database().reference().child(root).childByAutoId()
                }
                
                dbRef.setValue(photoData, withCompletionBlock: { (error, dbRef) in
                    
                    guard error == nil else { return }
                    
                    let sketch = Sketch(sketchId: dbRef.key!, byId: user!.userId!, byUsername: user!.usermname!, dateCreated: dateString, drawingUrl: drawingUrl!.absoluteString, imageUrl: imageUrl!.absoluteString)
                    
//                    getSketches { (sketches) in
//                        let updatedSketch = sketches.first { (sketch) -> Bool in
//                            sketch.sketchId == dateString
//                        }
//
//                        completion(updatedSketch!)
//                    }
                    
                    completion(sketch)
                })
            }
        }
    }
    
    static func downloadData(from urlString: String, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            //guard let self = self else { return }
            if error != nil { return }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return }
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                completion(data)
            }
        }
        
        task.resume()
    }
}
