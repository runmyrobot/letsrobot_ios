//
//  LoginView.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class LoginView: UIView {
    
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var usernameField: UITextField!
    
    var success: (() -> Void)?
    
    class func createView() -> LoginView {
        let viewNib = UINib(nibName: "LoginView", bundle: nil)
        
        guard let view = viewNib.instantiate(withOwner: self, options: nil).first as? LoginView else {
            fatalError()
        }
        
        view.load()
        
        return view
    }
    
    func load() {
        let usernameContainer = usernameField.superview
        usernameContainer?.backgroundColor = .clear
        usernameContainer?.layer.borderColor = UIColor.white.cgColor
        usernameContainer?.layer.borderWidth = 1
        
        let passwordContainer = passwordField.superview
        passwordContainer?.backgroundColor = .clear
        passwordContainer?.layer.borderColor = UIColor.white.cgColor
        passwordContainer?.layer.borderWidth = 1
        
        usernameField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)
        ])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)
        ])
        
        errorLabel.text = " "
    }
    
    @IBAction func didPressLogin() {
        let usernameContainer = usernameField.superview
        guard let username = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), username != "" else {
            usernameContainer?.layer.borderColor = UIColor.red.cgColor
            errorLabel.text = "Username field is required!"
            return
        }
        
        usernameContainer?.layer.borderColor = UIColor.white.cgColor
        
        let passwordContainer = passwordField.superview
        guard let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines), password != "" else {
            passwordContainer?.layer.borderColor = UIColor.red.cgColor
            errorLabel.text = "Password field is required!"
            return
        }
        
        passwordContainer?.layer.borderColor = UIColor.white.cgColor
        
        User.authenticate(userString: username, passString: password) { [weak self] (_, error) in
            if let error = error as? RobotError {
                switch error {
                case .invalidLoginDetails:
                    self?.errorLabel.text = "Incorrect login details!"
                default:
                    self?.errorLabel.text = "Something went wrong!"
                }
                
                return
            }
            
            self?.success?()
        }
    }

}
