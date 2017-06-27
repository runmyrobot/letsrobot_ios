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
        let usernameRaw = fieldValue(for: usernameField)
        
        if let usernameError = validateUsername(usernameRaw) {
            UIView.animate(withDuration: 0.3) {
                self.usernameLabel.textColor = self.errorColour
                self.usernameIndicator.backgroundColor = self.errorColour
                self.usernameLabel.alpha = 1
                self.usernameIndicator.alpha = 1
            }
            
            parent?.showMessage(usernameError, type: .error, options: [.textNumberOfLines(0)])
            return
        }
        
        clearError(field: usernameField)
        
        let passwordRaw = fieldValue(for: passwordField)
        
        if let passwordError = validatePassword(passwordRaw) {
            UIView.animate(withDuration: 0.3) {
                self.passwordLabel.textColor = self.errorColour
                self.passwordIndicator.backgroundColor = self.errorColour
                self.passwordLabel.alpha = 1
                self.passwordIndicator.alpha = 1
            }
            
            parent?.showMessage(passwordError, type: .error, options: [.textNumberOfLines(0)])
            return
        }
        
        clearError(field: passwordField)
        
        let emailRaw = fieldValue(for: emailField)
        
        if let emailError = validateEmail(emailRaw) {
            UIView.animate(withDuration: 0.3) {
                self.emailLabel.textColor = self.errorColour
                self.emailIndicator.backgroundColor = self.errorColour
                self.emailLabel.alpha = 1
                self.emailIndicator.alpha = 1
            }
            
            parent?.showMessage(emailError, type: .error, options: [.textNumberOfLines(0)])
            return
        }
        
        clearError(field: emailField)
        
        guard let username = usernameRaw,
              let password = passwordRaw,
              let email    = emailRaw else { return }
        
        parent?.view.endEditing(true)
        registerButton.setTitle(nil, for: .normal)
        registerButton.isUserInteractionEnabled = false
        registerIndicator.startAnimating()
        
        User.register(username: username, password: password, email: email) { [weak self] error in
            self?.registerIndicator.stopAnimating()
            
            if let error = error as? RobotError {
                self?.registerButton.setTitle("Register", for: .normal)
                self?.registerButton.isUserInteractionEnabled = true
                self?.parent?.showMessage(error.localizedDescription, type: .error, options: [.textNumberOfLines(0)])
                return
            }
            
            self?.registerButton.setTitle("Success", for: .normal)
            NotificationCenter.default.post(name: NSNotification.Name("LoginStatusChanged"), object: nil)
            
            self?.parent?.showMessage("Successfully registered!", type: .success)
            
            Threading.run(on: .main, after: 0.4) {
                self?.parent?.dismiss(animated: true, completion: nil)
            }
        }
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
    
    func validateUsername(_ username: String?) -> String? {
        guard let username = username else { return "Username field is mandatory!" }
        
        guard (username.matches(pattern: "^([a-zA-Z0-9_-]{3,15})$").first?.count ?? 0) > 0 else {
            return "Username must be between 3 and 15 characters, and only contain letters and numbers!"
        }
        
        guard (username.matches(pattern: "(faggot|nigger|cunt|fuck)").first?.count ?? 0) == 0 else {
            return "Username must not contain profanity!"
        }
        
        return nil
    }
    
    func validatePassword(_ password: String?) -> String? {
        guard let password = password else { return "Password field is mandatory!" }
        
        guard (password.matches(pattern: "^((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,})$").first?.count ?? 0) > 0 else {
            return "Password must contain at least 8 characters: Must contain at least 1 uppercase, 1 lowercase and 1 number!"
        }
        
        return nil
    }
    
    func validateEmail(_ email: String?) -> String? {
        guard let email = email else { return "Email field is mandatory!" }
        
        guard (email.matches(pattern: "(\\b[\\w\\.-]+@[\\w\\.-]+\\.\\w{2,4}\\b)").first?.count ?? 0) > 0 else {
            return "Email is not in a valid format!"
        }
        
        return nil
    }
}
