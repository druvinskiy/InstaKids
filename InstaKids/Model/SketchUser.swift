//
//  SketchUser.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/18/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct SketchUser: Hashable {
    var userId: String?
    var username: String?
    
    init?(snapshot:DataSnapshot) {
        
        let userData = snapshot.value as? [String:String]
        
        if let userData = userData {
            
            let userId = snapshot.key
            let usermname = userData["username"]
            
            guard usermname != nil else {
                return nil
            }
            
            self.userId = userId
            self.username = usermname
            
        } else {
            return nil
        }
    }
    
    init(userId: String, username: String) {
        self.userId = userId
        self.username = username
    }
}
