//
//  UserListTableViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 23/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke

class UserListTableViewCell: UITableViewCell {

    @IBOutlet var moderateUserButton: UIButton!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    var user: User!
    var robot: Robot?
    weak var parent: UIViewController?
    
    func loadUser(_ user: User) {
        self.user = user
        nameLabel.text = user.username
        nameLabel.textColor = user.usernameColor ?? .white
        
        if let url = user.avatarUrl {
            Nuke.loadImage(with: url, into: userImageView)
        } else {
            userImageView.image = nil
        }
        
        if let user = User.current {
            let role = user.role(for: robot)
            
            switch role {
            case .staff, .globalModerator, .moderator:
                return
            default:
                moderateUserButton.isHidden = true
            }
        } else {
            moderateUserButton.isHidden = true
        }
    }
    
    @IBAction func didPressModerateUser() {
        guard let modal = ModerateModalViewController.createModal(for: user, robot: robot) else { return }
        parent?.present(modal, animated: true, completion: nil)
    }
}
