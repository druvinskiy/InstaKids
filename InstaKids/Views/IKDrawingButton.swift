//
//  IKDrawingButton.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 4/1/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

class IKDrawingButton: UIBarButtonItem {
    
    var isHidden: Bool {
        get {
            return tintColor == UIColor.clear
        }
        set(hide) {
            if hide {
                isEnabled = false
                tintColor = UIColor.clear
            } else {
                tintColor = .white
            }
        }
    }
    
    init(title: String, style: UIBarButtonItem.Style, target: Any, action: Selector, isHidden: Bool = true) {
        super.init()
        
        self.title = title
        self.style = style
        self.target = target as AnyObject
        self.action = action
        self.isHidden = isHidden
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
