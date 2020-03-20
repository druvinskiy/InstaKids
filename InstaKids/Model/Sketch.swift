//
//  Sketch.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/16/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation
import PencilKit

//class Sketch: Codable, Equatable {
//    var thumbnailImage: UIImage
//    var drawing: PKDrawing
//    var dateCreated: Date
//
//    enum CodingKeys: CodingKey {
//        case thumbnailImage, drawing, dateCreated
//    }
//
//    init(thumbnailImage: UIImage, drawing: PKDrawing, dateCreated: Date) {
//        self.thumbnailImage = thumbnailImage
//        self.drawing = drawing
//        self.dateCreated = dateCreated
//    }
//
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        let thumnailData = try container.decode(Data.self, forKey: .thumbnailImage)
//        thumbnailImage = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(thumnailData) as! UIImage
//
//        let drawingData = try container.decode(Data.self, forKey: .drawing)
//        drawing = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(drawingData) as! PKDrawing
//
//        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        let thumnailData = try NSKeyedArchiver.archivedData(withRootObject: thumbnailImage, requiringSecureCoding: false)
//        try container.encode(thumnailData, forKey: .thumbnailImage)
//
//        let drawingData = try NSKeyedArchiver.archivedData(withRootObject: drawing, requiringSecureCoding: false)
//        try container.encode(drawingData, forKey: .drawing)
//
//        try container.encode(dateCreated, forKey: .dateCreated)
//    }
//
//    static func == (lhs: Sketch, rhs: Sketch) -> Bool {
//        lhs.dateCreated == rhs.dateCreated
//    }
//}

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
    //var thumbnailImage: UIImage?
    //var drawing: PKDrawing?
    var dateCreated: String?
    var drawingUrl: String?
    var imageUrl: String?
    
//    enum CodingKeys: CodingKey {
//        case sketchId, byId, byUsername, thumbnailImage, drawing, dateCreated, url
//    }
    
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
    
//    init(thumbnailImage: UIImage, drawing: PKDrawing, dateCreated: Date) {
//        self.thumbnailImage = thumbnailImage
//        self.drawing = drawing
//        self.dateCreated = dateCreated
//    }
    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        let thumnailData = try container.decode(Data.self, forKey: .thumbnailImage)
//        thumbnailImage = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(thumnailData) as? UIImage
//
//        let drawingData = try container.decode(Data.self, forKey: .drawing)
//        drawing = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(drawingData) as? PKDrawing
//
//        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
////        try container.encode(photoId, forKey: .photoId)
//
//        let sketchIdData = try NSKeyedArchiver.archivedData(withRootObject: sketchId, requiringSecureCoding: false)
//        try container.encode(sketchId, forKey: .sketchId)
//
//        let byIdData = try NSKeyedArchiver.archivedData(withRootObject: byId, requiringSecureCoding: false)
//        try container.encode(byId, forKey: .byId)
//
////        try container.encode(byId, forKey: .byId)
//
//        let byUsernameData = try NSKeyedArchiver.archivedData(withRootObject: byUsername, requiringSecureCoding: false)
//        try container.encode(byUsernameData, forKey: .byUsername)
//
////        try container.encode(byUsername, forKey: .byUsername)
//
//        let thumnailData = try NSKeyedArchiver.archivedData(withRootObject: thumbnailImage, requiringSecureCoding: false)
//        try container.encode(thumnailData, forKey: .thumbnailImage)
//
//        let drawingData = try NSKeyedArchiver.archivedData(withRootObject: drawing, requiringSecureCoding: false)
//        try container.encode(drawingData, forKey: .drawing)
//
//        let urlData = try NSKeyedArchiver.archivedData(withRootObject: drawing, requiringSecureCoding: false)
//        try container.encode(urlData, forKey: .url)
//
////        try container.encode(drawing, forKey: .drawing)
//
//        try container.encode(dateCreated, forKey: .dateCreated)
//    }
    
    static func == (lhs: Sketch, rhs: Sketch) -> Bool {
        lhs.dateCreated == rhs.dateCreated
    }
}

