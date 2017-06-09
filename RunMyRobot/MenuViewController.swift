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
    typealias MenuItem = (title: String, imageName: String, action: String)
    
    @IBOutlet var loginLogoImageView: UIImageView!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var tableViewToUsernameConstraint: NSLayoutConstraint!
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet var usernameLabel: TTTAttributedLabel!
    @IBOutlet var profileImageView: UIImageView!
    
    var menuItems: [MenuItem] {
        let shared = [
            ("Join Discord", "Social/discord", "ShowDiscord"),
            ("Support Us", "Social/patreon", "ShowPatreon"),
            ("Follow Us", "Social/twitter", "ShowTwitter"),
            ("Donate", "Social/paypal", "ShowPayPal"),
            ("Source Code", "Social/github", "ShowGitHub")
        ]
        
        if !AuthenticatedUser.loggedIn {
            return [
                ("Login", "Menu/login", "ShowLogin"),
                ("Register", "Menu/register", "ShowRegister")
            ] + shared
        }
        
        return [
            ("Settings", "Menu/settings", "ShowSettings"),
            ("My Robots", "Menu/robots", "ShowRobots")
        ] + shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.estimatedRowHeight = 80
        menuTableView.rowHeight = UITableViewAutomaticDimension
        
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2
        
        if AuthenticatedUser.loggedIn {
            usernameLabel.text = AuthenticatedUser.current?.username ?? "Sherlouk"
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = menuItems[indexPath.item]
        
        switch item.action {
        case "ShowLogin":
            performSegue(withIdentifier: "ShowLogin", sender: "login")
        case "ShowRegister":
            performSegue(withIdentifier: "ShowLogin", sender: "register")
        default:
            print("❓ Unknown Action: \(item.action)!")
            break
        }
    }
    
}
