//
//  ForgottenPasswordForm.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 24/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class ForgottenPasswordForm: UIView {

    weak var parent: UIViewController?
    
    class func create(parent: UIViewController) -> ForgottenPasswordForm {
        let views = UINib(nibName: "LoginView", bundle: nil).instantiate(withOwner: self, options: nil) as? [UIView]
        
        guard let view = views?.first(where: { $0 is ForgottenPasswordForm }) as? ForgottenPasswordForm else {
            fatalError()
        }
        
        view.backgroundColor = .clear
        view.parent = parent
        return view
    }

}
