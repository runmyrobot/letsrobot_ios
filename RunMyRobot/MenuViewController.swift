//
//  MenuViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 07/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class MenuViewController: UIViewController {
    typealias MenuItem = (title: String, imageName: String)
    
    @IBOutlet var loginLogoImageView: UIImageView!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var tableViewToUsernameConstraint: NSLayoutConstraint!
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet var usernameLabel: TTTAttributedLabel!
    @IBOutlet var profileImageView: UIImageView!
    
    var menuItems: [MenuItem] {
        let shared = [
            ("Join Discord", "Social/discord"),
            ("Support Us", "Social/patreon"),
            ("Follow Us", "Social/twitter"),
            ("Donate", "Social/paypal"),
            ("Source Code", "Social/github")
        ]
        
        if !AuthenticatedUser.loggedIn {
            return [
                ("Login", "Menu/login"),
                ("Register", "Menu/register")
            ] + shared
        }
        
        return [
            ("Settings", "Menu/settings"),
            ("My Robots", "Menu/robots")
        ] + shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.estimatedRowHeight = 80
        menuTableView.rowHeight = UITableViewAutomaticDimension
        
        profileImageView.layer.borderColor = UIColor.red.cgColor
        profileImageView.layer.borderWidth = 3
        
        if AuthenticatedUser.loggedIn {
            usernameLabel.text = AuthenticatedUser.current?.username
            loginLogoImageView.isHidden = true
        } else {
            profileImageView.isHidden = true
            usernameLabel.isHidden = true
            logoutButton.isHidden = true
            tableViewToUsernameConstraint.isActive = false
        }
    }
    @IBAction func didPressLogout() {
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItem", for: indexPath) as? MenuListItemCell else {
            fatalError()
        }
        
        let item = menuItems[indexPath.item]
        cell.configure(title: item.title, image: item.imageName)
        return cell
    }
    
}
