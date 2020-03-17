//
//  Sketch.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/16/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation
import PencilKit

class Sketch: Codable {
    var thumbnailImage: UIImage
    var drawing: PKDrawing
    
    enum CodingKeys: CodingKey {
        case thumbnailImage, drawing
    }
    
    init(thumbnailImage: UIImage, drawing: PKDrawing) {
        self.thumbnailImage = thumbnailImage
        self.drawing = drawing
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let thumnailData = try container.decode(Data.self, forKey: .thumbnailImage)
        thumbnailImage = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(thumnailData) as! UIImage
      
        
        let drawingData = try container.decode(Data.self, forKey: .drawing)
        drawing = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(drawingData) as! PKDrawing
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let thumnailData = try NSKeyedArchiver.archivedData(withRootObject: thumbnailImage, requiringSecureCoding: false)
        try container.encode(thumnailData, forKey: .thumbnailImage)
        
        let drawingData = try NSKeyedArchiver.archivedData(withRootObject: drawing, requiringSecureCoding: false)
        try container.encode(drawingData, forKey: .drawing)
    }
    
}
