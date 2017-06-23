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

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    func loadUser(_ user: User) {
        nameLabel.text = user.username
        
        if let url = user.avatarUrl {
            Nuke.loadImage(with: url, into: userImageView)
        }
    }
}
