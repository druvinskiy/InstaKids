//
//  IKImageView.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/22/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

class IKImageView: UIImageView {
    let placeholderImage = UIImage(named: "UserIcon")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage!
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func downloadImage(from urlString: String) {
        SketchService.downloadData(from: urlString) { (result) in
            
            switch result {
                
            case .success(let data):
                
                guard let image = UIImage(data: data) else { return }
                DispatchQueue.main.async { self.image = image }
                
            case .failure(_):
                break
            }
        }
    }
}
