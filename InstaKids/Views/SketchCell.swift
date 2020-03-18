//
//  SketchCell.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/17/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

class SketchCell: UITableViewCell {
    
    static let reuseID = "SketchCellID"
    
    @IBOutlet weak var testImageView: UIImageView!
    func set(with thumbnail: UIImage?){
        testImageView.image = thumbnail
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
