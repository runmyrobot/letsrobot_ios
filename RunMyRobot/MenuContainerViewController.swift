//
//  MenuContainerViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 07/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class MenuContainerViewController: SlideMenuController {

    override func viewDidLoad() {
        super.viewDidLoad()

        SlideMenuOptions.simultaneousGestureRecognizers = false
        SlideMenuOptions.contentViewOpacity = 0.6
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.hideStatusBar = false
        
        if let main = storyboard?.instantiateViewController(withIdentifier: "MainView") {
            mainViewController = main
        }
        
        if let left = storyboard?.instantiateViewController(withIdentifier: "MenuView") {
            leftViewController = left
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
