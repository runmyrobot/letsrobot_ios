//
//  LoginForm.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 24/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import GSMessages

class LoginForm: UIView {
    
    @IBOutlet var usernameLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var usernameIndicator: UIView!
    
    @IBOutlet var passwordLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var passwordIndicator: UIView!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginIndicator: UIActivityIndicatorView!
    
    var parent: UIViewController?
    let errorColour = GSMessage.errorBackgroundColor
    
    class func create() -> LoginForm {
        let views = UINib(nibName: "LoginView", bundle: nil).instantiate(withOwner: self, options: nil) as? [UIView]
        
        guard let view = views?.first(where: { $0 is LoginForm }) as? LoginForm else {
            fatalError()
        }
        
        view.backgroundColor = .clear
        return view
    }
    
    @IBAction func didPressLogin() {
        guard let username = fieldValue(for: usernameField) else {
            UIView.animate(withDuration: 0.3) {
                self.usernameLabel.textColor = self.errorColour
                self.usernameIndicator.backgroundColor = self.errorColour
                self.usernameLabel.alpha = 1
                self.usernameIndicator.alpha = 1
            }
            
            showMessage("The username field is mandatory!", type: .error)
            return
        }
        
        clearError(field: usernameField)
        
        guard let password = fieldValue(for: passwordField) else {
            UIView.animate(withDuration: 0.3) {
                self.passwordLabel.textColor = self.errorColour
                self.passwordIndicator.backgroundColor = self.errorColour
                self.passwordLabel.alpha = 1
                self.passwordIndicator.alpha = 1
            }
            
            showMessage("The password field is mandatory!", type: .error)
            return
        }
        
        clearError(field: passwordField)
        
        parent?.view.endEditing(true)
        loginButton.setTitle(nil, for: .normal)
        loginButton.isUserInteractionEnabled = false
        loginIndicator.startAnimating()
        
        User.authenticate(userString: username, passString: password) { _, error in
            self.loginIndicator.stopAnimating()
            
            if let error = error as? RobotError {
                self.loginButton.setTitle("Log In", for: .normal)
                self.loginButton.isUserInteractionEnabled = true
                switch error {
                case .invalidLoginDetails:
                    self.showMessage("Incorrect login details, try again.", type: .error)
                default:
                    self.showMessage("Something went wrong, try again later.", type: .error)
                }
                return
            }
            
            self.loginButton.setTitle("Completed", for: .normal)
            
            NotificationCenter.default.post(name: NSNotification.Name("LoginStatusChanged"), object: nil)
            self.showMessage("Successful Login!", type: .success)
            
            Threading.run(on: .main, after: 0.2) {
                self.parent?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func didStartEditingField(_ sender: UITextField) {
        select(field: sender)
    }
    
    func clearError(field: UITextField) {
        let isUsername = field.tag == 1
        
        UIView.animate(withDuration: 0.3) {
            if isUsername {
                self.usernameLabel.textColor = .white
                self.usernameIndicator.backgroundColor = .white
            } else {
                self.passwordLabel.textColor = .white
                self.passwordIndicator.backgroundColor = .white
            }
        }
    }
    
    func select(field: UITextField) {
        let isUsername = field.tag == 1
        
        if isUsername {
            usernameLabelCenterYConstraint.isActive = false
            if fieldValue(for: passwordField) == nil {
                passwordLabelCenterYConstraint.isActive = true
            }
            
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
                self.usernameLabel.alpha = 1
                self.usernameIndicator.alpha = 1
                
                if self.fieldValue(for: self.passwordField) == nil && self.passwordLabel.textColor != self.errorColour {
                    self.passwordLabel.alpha = 0.3
                    self.passwordIndicator.alpha = 0.3
                }
            }
        } else {
            passwordLabelCenterYConstraint.isActive = false
            if fieldValue(for: usernameField) == nil {
                usernameLabelCenterYConstraint.isActive = true
            }
            
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
                self.passwordLabel.alpha = 1
                self.passwordIndicator.alpha = 1
                
                if self.fieldValue(for: self.usernameField) == nil && self.usernameLabel.textColor != self.errorColour {
                    self.usernameLabel.alpha = 0.3
                    self.usernameIndicator.alpha = 0.3
                }
            }
        }
    }
    
    func fieldValue(for field: UITextField) -> String? {
        let rawText = field.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if rawText == "" {
            return nil
        }
        
        return rawText
    }
    
}
