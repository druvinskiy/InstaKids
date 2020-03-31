//
//  ReAuthenticationViewModel.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/30/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthenticationViewModel {
    
    var isFormValid = Bindable<Bool>()
    var isAuthenticating = Bindable<Bool>()
    
    var password: String? { didSet { checkFormValidity() } }
    
    fileprivate func checkFormValidity() {
        let isValid = password?.isEmpty == false
        isFormValid.value = isValid
    }
    
    func performAuthentication(completion: @escaping (Error?) -> ()) {
        isAuthenticating.value = true
        
        let user = Auth.auth().currentUser
        guard let password = password, let email = user?.email else { return }
        
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user?.reauthenticate(with: credential, completion: { (result, error) in
            
            completion(error)
        })
    }
}
