//
//  LoginViewController.swift
//  InstaKids
//
//  Created by David Ruvinskiy on 3/18/20.
//  Copyright © 2020 David Ruvinskiy. All rights reserved.
//

import UIKit
import FirebaseUI

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        //Create a firebase auth ui object
        let authUI = FUIAuth.defaultAuthUI()
        
        //Check that it isn't nil
        if let authUI = authUI {
            
            //Set the login view controller as the delegate
            authUI.delegate = self
            authUI.providers = [FUIEmailAuth()]
            
            //Create a firebase auth pre build UI View Controller
            let authViewController = authUI.authViewController()
            
            //Present it
            present(authViewController, animated: true, completion: nil)
        }
    }
}

extension LoginViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        
        //Check if an error occurred
        guard error == nil else {
            print("An error has happened")
            return
        }
        
        //Check if user is nil
        if let user = user {
            
            user.reload { (error) in
                switch user.isEmailVerified {
                case true:
                    print("user email is verified")
                    
                    //This means that we have a user, now check if they have a profile
                    
                    UserService.getUserProfile(userId: user.uid) { (u) in
                        
                        if u == nil {
                            let createProfileVC = CreateProfileViewController()
                            createProfileVC.window = self.view.window
                            
                            self.present(createProfileVC, animated: true)
                        }
                        else {
                            
                            //Save the logged in user to local storgage
                            LocalStorageService.saveCurrentUser(user: u!)
                            
                            //This user has a profile, go to tab controller
                            let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController)
                            
                            self.view.window?.rootViewController = tabBarVC
                            self.view.window?.makeKeyAndVisible()
                        }
                    }
                    
                case false:
                    user.sendEmailVerification { (error) in
                        guard error == nil else {
                            return
                        }
                    }
                }
            }
        }
    }
}
