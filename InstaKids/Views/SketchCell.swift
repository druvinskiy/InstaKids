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
    @IBOutlet weak var usernameLabel: UILabel!
    
    func set(with sketch: Sketch, _ isFeed: Bool){
        dateLabel.text = sketch.dateCreated
        
        usernameLabel.text = isFeed
            ? sketch.byUsername
            : ""
        
        guard let imageUrl = sketch.imageUrl else { return }
        
        SketchService.downloadData(from: imageUrl) { (result) in
            
            switch result {
                
            case .success(let data):
                self.sketchImageView.image = UIImage(data: data)
                
            case .failure(_):
                break
            }
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
