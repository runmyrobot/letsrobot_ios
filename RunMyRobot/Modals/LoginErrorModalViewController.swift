//
//  LoginErrorModalViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 28/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class LoginErrorModalViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    class func create() -> LoginErrorModalViewController {
        let storyboard = UIStoryboard(name: "Modals", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "LoginError") as? LoginErrorModalViewController else {
            fatalError()
        }
        
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CurrentUser.loggedIn {
            dismiss(animated: true, completion: nil)
        }
    }
    
}
