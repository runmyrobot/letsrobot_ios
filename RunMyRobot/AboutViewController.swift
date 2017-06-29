//
//  AboutViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 29/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UIViewController {
    
    @IBOutlet var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = AppDelegate.current?.currentVersionDescription
    }
    
    @IBAction func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressGiveRating() {
        AppDelegate.current?.openAppStore(action: "write-review")
    }

    @IBAction func didPressShowSourceCode() {
        launchWebModule(urlString: "https://github.com/runmyrobot/letsrobot_ios")
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
