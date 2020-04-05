//
//  UIViewControllerExtension.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/30/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentIKAlertOnMainThread(title: String, message: String, positiveButtonTitle: String?, positiveButtonAction: @escaping (() -> Void), negativeButtonTitle: String?, negativeButtonAction: (() -> Void)?) {
        
        DispatchQueue.main.async {
            let alertVC = IKAlertVC(title: title, message: message, positiveButtonTitle: positiveButtonTitle, positiveButtonAction: positiveButtonAction, negativeButtonTitle: negativeButtonTitle, negativeButtonAction: negativeButtonAction)
            
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true)
        }
    }
}
