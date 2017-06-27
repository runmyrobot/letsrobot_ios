//
//  RegisterForm.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 24/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import GSMessages

class RegisterForm: UIView {

    @IBOutlet var usernameLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var usernameIndicator: UIView!
    
    @IBOutlet var passwordLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var passwordIndicator: UIView!
    
    @IBOutlet var emailLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailIndicator: UIView!
    
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var registerIndicator: UIActivityIndicatorView!
    
    weak var parent: UIViewController?
    let errorColour = GSMessage.errorBackgroundColor
    
    class func create(parent: UIViewController) -> RegisterForm {
        let views = UINib(nibName: "LoginView", bundle: nil).instantiate(withOwner: self, options: nil) as? [UIView]
        
        guard let view = views?.first(where: { $0 is RegisterForm }) as? RegisterForm else {
            fatalError()
        }
        
        view.backgroundColor = .clear
        view.parent = parent
        return view
    }

    @IBAction func didPressRegister() {
        
    }
    
    @IBAction func didStartEditingField(_ sender: UITextField) {
        select(field: sender)
    }
    
    func clearError(field: UITextField) {
        UIView.animate(withDuration: 0.3) {
            switch field.tag {
            case 1:
                self.usernameLabel.textColor = .white
                self.usernameIndicator.backgroundColor = .white
                break
            case 2:
                self.passwordLabel.textColor = .white
                self.passwordIndicator.backgroundColor = .white
                break
            case 3:
                self.emailLabel.textColor = .white
                self.emailIndicator.backgroundColor = .white
                break
            default:
                break
            }
        }
    }
    
    func select(field: UITextField) {
        switch field.tag {
        case 1:
            usernameLabelCenterYConstraint.isActive = false
            
            if fieldValue(for: passwordField) == nil {
                passwordLabelCenterYConstraint.isActive = true
            }
            
            if fieldValue(for: emailField) == nil {
                emailLabelCenterYConstraint.isActive = true
            }
            
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
                self.usernameLabel.alpha = 1
                self.usernameIndicator.alpha = 1
                
                if self.fieldValue(for: self.passwordField) == nil && self.passwordLabel.textColor != self.errorColour {
                    self.passwordLabel.alpha = 0.3
                    self.passwordIndicator.alpha = 0.3
                }
                
                if self.fieldValue(for: self.emailField) == nil && self.emailLabel.textColor != self.errorColour {
                    self.emailLabel.alpha = 0.3
                    self.emailIndicator.alpha = 0.3
                }
            }
            break
        case 2:
            passwordLabelCenterYConstraint.isActive = false
            
            if fieldValue(for: usernameField) == nil {
                usernameLabelCenterYConstraint.isActive = true
            }
            
            if fieldValue(for: emailField) == nil {
                emailLabelCenterYConstraint.isActive = true
            }
            
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
                self.passwordLabel.alpha = 1
                self.passwordIndicator.alpha = 1
                
                if self.fieldValue(for: self.usernameField) == nil && self.usernameLabel.textColor != self.errorColour {
                    self.usernameLabel.alpha = 0.3
                    self.usernameIndicator.alpha = 0.3
                }
                
                if self.fieldValue(for: self.emailField) == nil && self.emailLabel.textColor != self.errorColour {
                    self.emailLabel.alpha = 0.3
                    self.emailIndicator.alpha = 0.3
                }
            }
            break
        case 3:
            emailLabelCenterYConstraint.isActive = false
            
            if fieldValue(for: usernameField) == nil {
                usernameLabelCenterYConstraint.isActive = true
            }
            
            if fieldValue(for: passwordField) == nil {
                passwordLabelCenterYConstraint.isActive = true
            }
            
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
                self.emailLabel.alpha = 1
                self.emailIndicator.alpha = 1
                
                if self.fieldValue(for: self.usernameField) == nil && self.usernameLabel.textColor != self.errorColour {
                    self.usernameLabel.alpha = 0.3
                    self.usernameIndicator.alpha = 0.3
                }
                
                if self.fieldValue(for: self.passwordField) == nil && self.passwordLabel.textColor != self.errorColour {
                    self.passwordLabel.alpha = 0.3
                    self.passwordIndicator.alpha = 0.3
                }
            }
            break
        default:
            break
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
