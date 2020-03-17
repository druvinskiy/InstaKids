//
//  SketchCell.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/16/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation

import UIKit

class SketchCell: UITableViewCell {
    
  @IBOutlet weak var thumbnailImageView: UIImageView!
  
  var sketchImage: UIImage? {
    didSet {
      if let image = sketchImage {
        thumbnailImageView.image = image
      }
    }
  }
}
