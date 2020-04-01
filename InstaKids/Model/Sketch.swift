//
//  Sketch.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/16/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation
import PencilKit
import FirebaseDatabase

class Sketch: Codable, Equatable {
    var sketchId:String?
    var byId:String?
    var byUsername:String?
    var dateCreated: String?
    var drawingUrl: String?
    var imageUrl: String?
    
    init?(snapshot:DataSnapshot) {
        
        //Sketch data
        let sketchData = snapshot.value as? [String:String]
        
        if let sketchData = sketchData {
            
            let sketchId = snapshot.key
            let byId = sketchData["byId"]
            let byUsername = sketchData["byUsername"]
            let date = sketchData["date"]
            let drawingUrl = sketchData["drawingUrl"]
            let imageUrl = sketchData["imageUrl"]
            
            guard byId != nil && byUsername != nil && date != nil && imageUrl != nil else {
                return nil
            }
            
            self.sketchId = sketchId
            self.byId = byId
            self.byUsername = byUsername
            self.dateCreated = date
            self.drawingUrl = drawingUrl
            self.imageUrl = imageUrl
        }
    }
    
    init(sketchId: String, byId: String, byUsername: String, dateCreated: String, drawingUrl: String, imageUrl: String) {
        self.sketchId = sketchId
        self.byId = byId
        self.byUsername = byUsername
        self.dateCreated = dateCreated
        self.drawingUrl = drawingUrl
        self.imageUrl = imageUrl
    }
    
    static func == (lhs: Sketch, rhs: Sketch) -> Bool {
        lhs.dateCreated == rhs.dateCreated
    }
    
//    func hash(into hasher: inout Hasher) {
//        <#code#>
//    }
}

