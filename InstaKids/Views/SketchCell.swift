//
//  SketchCell.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/16/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

class SketchCell: UITableViewCell {
    static let reuseID = "SketchCellID"
    let thumbnailImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(with thumbnail: UIImage?){
        thumbnailImageView.image = thumbnail
    }
    
    private func configure(){
        let padding : CGFloat = 10
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFit
        addSubview(thumbnailImageView)
                
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            thumbnailImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding),
            thumbnailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            thumbnailImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding)
        ])
    }
}
