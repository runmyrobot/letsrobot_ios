//
//  ModerateModalViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 30/06/2017.
//  Copyright © 2017 Let's Robot. All rights reserved.
//

import UIKit
import PopupDialog

class ModerateModalViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeoutButton: UIButton!
    @IBOutlet var blockButton: UIButton!
    @IBOutlet var globalBlockButton: UIButton!
    
    var user: User!
    var robot: Robot?
    var role: UserRole!
    
    class func create(for user: User, robot: Robot?) -> ModerateModalViewController {
        let storyboard = UIStoryboard(name: "Modals", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ModerateUser") as? ModerateModalViewController else {
            fatalError()
        }
        
        vc.user = user
        vc.robot = robot
        return vc
    }
    
    class func createModal(for user: User, robot: Robot?) -> PopupDialog? {
        guard let currentUser = User.current else { return nil }
        let supportedRanks: [UserRole] = [.staff, .globalModerator, .moderator]
        guard supportedRanks.contains(currentUser.role(for: robot)) else { return nil }
        
        let modal = create(for: user, robot: robot)
        return PopupDialog(viewController: modal, transitionStyle: .zoomIn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Moderating user: \(user.username)"
        
        guard let currentUser = User.current else { return }
        role = currentUser.role(for: robot)
        
        if role == .staff || role == .globalModerator {
            timeoutButton.setTitle("Global Timeout", for: .normal)
        } else {
            globalBlockButton.removeFromSuperview()
        }
        
        if robot == nil {
            timeoutButton.isEnabled = false
            blockButton.isEnabled = role != .moderator
        }
    }

    @IBAction func didPressAction(_ sender: UIButton) {
        guard CurrentUser.loggedIn else { return }
        
        switch sender.tag {
        case 1:
            guard let robot = robot else { return }
            Socket.shared.timeout(user: user, robot: robot)
        case 2:
            if role == .moderator {
                guard let robot = robot else { return }
                Socket.shared.blockForRobocaster(user: user, robot: robot)
            } else {
                Socket.shared.block(user: user)
            }
        case 3:
            Socket.shared.block(user: user, global: true)
        default:
            return
        }
    }
}
