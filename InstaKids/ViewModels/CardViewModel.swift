//
//  CardViewModel.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/25/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    let uid: String
    let imageUrl: String
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    var imageIndexObserver: ((Int, String?) -> ())?
    
    init(uid: String, imageName: String, attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.uid = uid
        self.imageUrl = imageName
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
}
