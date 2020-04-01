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
    var profileImageUrl: String?
    var following = [String]()
    
    init?(snapshot:DataSnapshot) {
        
        let userData = snapshot.value as? [String:Any]
        
        if let userData = userData {
            
            let userId = snapshot.key
            let usermname = userData["username"]
            let profileImageUrl = userData["profileImageUrl"]
            let following = userData["following"] as? [String : Bool]
            
            guard usermname != nil, profileImageUrl != nil else {
                return nil
            }
            
            following?.forEach({ (key, value) in
                self.following.append(key)
            })
            
            self.userId = userId
            self.username = usermname as? String
            self.profileImageUrl = profileImageUrl as? String
            
            
        } else {
            return nil
        }
    }
    
    init(userId: String, username: String, following: [String]?) {
        self.userId = userId
        self.username = username
        self.following = following ?? []
    }
    
    static func == (lhs: SketchUser, rhs: SketchUser) -> Bool {
        lhs.userId == rhs.userId
    }
}

extension SketchUser: ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel {
        let attributedText = NSMutableAttributedString(string: username ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        
        return CardViewModel(uid: self.userId ?? "", imageName: profileImageUrl ?? "", attributedString: attributedText, textAlignment: .left)
    }
}
