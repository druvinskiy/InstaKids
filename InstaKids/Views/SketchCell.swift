//
//  SketchCell.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/17/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

class SketchCell: UITableViewCell {
    
    @IBOutlet weak var sketchImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    func set(with sketch: Sketch){
        dateLabel.text = sketch.dateCreated
        
        guard let imageUrl = sketch.imageUrl else { return }
        
        SketchService.downloadData(from: imageUrl) { (data) in
            self.sketchImageView.image = UIImage(data: data)
        }
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
