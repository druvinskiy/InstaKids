//
//  RegistrationViewModel.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/22/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

class RegistrationViewModel {
    
    var binableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    
    var username: String? { didSet {checkFormValidity()} }
    var email: String? { didSet {checkFormValidity()} }
    
    func checkFormValidity() {
        let isFormValid = username?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    }
}
