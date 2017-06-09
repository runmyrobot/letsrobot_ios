//
//  LoginViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 09/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var passwordField: UITextField!
    @IBOutlet var usernameField: UITextField!
    
    @IBAction func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressLogin(_ sender: Any) {
        guard let username = usernameField.text else { return }
        guard let password = passwordField.text else { return }
        
        User.authenticate(user: username, pass: password) { _, error in
            NotificationCenter.default.post(name: NSNotification.Name("LoginStatusChanged"), object: nil)
            
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
