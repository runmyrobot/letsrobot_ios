//
//  MenuViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 07/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SafariServices
import Nuke

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
            ("Follow Us", "Social/twitter", "ShowTwitter"),
            ("Reddit", "Social/reddit", "ShowReddit"),
            ("Rules", "Menu/rules", "ShowRules"),
            ("About", "Menu/about", "ShowAbout")
        ]
        
        if !CurrentUser.loggedIn {
            let arr = [
                ("Login", "Menu/login", "ShowLogin"),
                ("Register", "Menu/register", "ShowRegister")
            ] as [MenuItem]
            return arr + shared
        }
        
        return [
            ("Settings", "Settings/cog", "ShowSettings"),
            ("My Robots", "Settings/bot", "ShowMyRobots")
        ] + shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.estimatedRowHeight = 80
        menuTableView.rowHeight = UITableViewAutomaticDimension
        
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLoginStatus), name: NSNotification.Name("LoginStatusChanged"), object: nil)
        
        updateLoginStatus()
    }
    
    func updateLoginStatus() {
        usernameLabel.text = User.current?.username
        usernameLabel.isHidden = !CurrentUser.loggedIn
        
        loginLogoImageView.isHidden = CurrentUser.loggedIn
        profileImageView.isHidden = !CurrentUser.loggedIn
        logoutButton.isHidden = !CurrentUser.loggedIn
        tableViewToUsernameConstraint.isActive = CurrentUser.loggedIn
        
        if let user = User.current {
            if let avatarUrl = user.avatarUrl {
                Nuke.loadImage(with: avatarUrl, into: profileImageView)
            }
            
            if profileImageView.image == nil {
                // Placeholder image
                profileImageView.image = UIImage(named: "logo")
            }
        }
        
        menuTableView.reloadData()
    }
    
    @IBAction func didPressLogout() {
        User.current?.logout()
    }
    
    func launchWebModule(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let viewController = SFSafariViewController(url: url)
        
        if #available(iOS 10.0, *) {
            viewController.preferredBarTintColor = UIColor.black
            viewController.preferredControlTintColor = UIColor.white
        }
        
        present(viewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRobotSettings", let destination = segue.destination as? RobotSettingsViewController {
            destination.robots = User.current?.robots ?? []
            
            for robot in destination.robots {
                robot.unsavedChanges = [RobotSettings: Any]()
            }
        } else if segue.identifier == "ShowLogin", let destination = segue.destination as? LoginViewController {
            destination.startPage = (sender as? String) == "register" ? 1 : 0
        }
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
        case "ShowDiscord":
            launchWebModule(urlString: "https://discord.gg/CpxUrk5")
        case "ShowGitHub":
            launchWebModule(urlString: "https://github.com/runmyrobot/letsrobot_ios")
        case "ShowReddit":
            launchWebModule(urlString: "https://www.reddit.com/r/letsRobot/")
        case "ShowTwitter":
            launchWebModule(urlString: "https://twitter.com/letsrobot")
        case "ShowSettings":
            performSegue(withIdentifier: "ShowSettings", sender: nil)
        case "ShowRules":
            performSegue(withIdentifier: "ShowRules", sender: nil)
        case "ShowMyRobots":
            performSegue(withIdentifier: "ShowRobotSettings", sender: nil)
        case "ShowAbout":
            performSegue(withIdentifier: "ShowAbout", sender: nil)
        default:
            print("❓ Unknown Action: \(item.action)!")
        }
    }
    
}
