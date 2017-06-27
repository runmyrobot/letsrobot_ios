//
//  LoaderViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 03/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PopupDialog

class LoaderViewController: UIViewController {

    @IBOutlet var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        progressLabel.text = "Downloading Config"
        
        Networking.requestJSON("/mobile/config.json") { [weak self] response in
            guard let rawJSON = response.result.value else {
                self?.progressLabel.text = "Error Downloading Config"
                print("Something went wrong!")
                return
            }
            
            self?.progressLabel.text = "Parsing Config"
            let json = JSON(rawJSON)
            
            let appId = json["appStoreId"].stringValue
            
            let appStore = DefaultButton(title: "Go to App Store", dismissOnTap: false) {
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appId)"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
            
            let forcedEnabed = json["forcedUpdate", "enabled"].boolValue
            if forcedEnabed, self?.needsUpdate(version: json["forcedUpdate", "minimum_version"].stringValue) == true {
                self?.progressLabel.text = "Outdated App"
                
                let dialog = PopupDialog(
                    title: json["forcedUpdate", "title"].string,
                    message: json["forcedUpdate", "message"].string,
                    gestureDismissal: false
                )
                
                dialog.addButtons([appStore])
                
                self?.present(dialog, animated: true, completion: nil)
                return
            }
            
            let recommendedEnabled = json["recommendedUpdate", "enabled"].boolValue
            if recommendedEnabled, self?.needsUpdate(version: json["recommendedUpdate", "minimum_version"].stringValue) == true {
                let dialog = PopupDialog(
                    title: json["forcedUpdate", "title"].string,
                    message: json["forcedUpdate", "message"].string,
                    gestureDismissal: false
                )
                
                let proceed = CancelButton(title: "Continue Anyway") {
                    self?.loadRobots()
                }
                
                dialog.addButtons([appStore, proceed])
                
                self?.present(dialog, animated: true, completion: nil)
                return
            }
            
            self?.loadRobots()
        }
    }
    
    private func loadRobots() {
        progressLabel.text = "Downloading Robots"
        
        Networking.requestJSON("/internal") { [weak self] response in
            guard let rawJSON = response.result.value else {
                self?.progressLabel.text = "Error Downloading Robots"
                print("Something went wrong!")
                return
            }
            
            let json = JSON(rawJSON)
            self?.progressLabel.text = "Converting Robots"
            let config = Config(json: json)
            Config.shared = config
            
            self?.progressLabel.text = "Loading Products"
            Networking.requestJSON("/api/v1/products") { [weak self] response in
                guard let rawProductJSON = response.result.value else {
                    self?.progressLabel.text = "Error Downloading Products"
                    print("Something went wrong!")
                    return
                }
                
                self?.progressLabel.text = "Converting Products"
                if let productsJson = JSON(rawProductJSON).array {
                    for productJson in productsJson {
                        _ = Product(productJson)
                    }
                }
                
                self?.validateUser(json)
            }
        }
    }
    
    // Set the current logged in user if already authenticated, otherwise ensure they're logged out
    // Continues the waterfall chain and start's the socket
    private func validateUser(_ json: JSON) {
        // If the user is already logged in, then maintain that status
        if let user = CurrentUser(json: json) {
            progressLabel.text = "Validating User"
            
            // Load and further validate the logged in user
            user.load { [weak self] _, error in
                // If we have any error, then log the user out - May need to be more specific down the line incase of network timeout error
                if error != nil {
                    self?.progressLabel.text = "Cleaning User"
                    user.logout {
                        self?.startSocket()
                    }
                } else {
                    user.updateRoles(json)
                    self?.startSocket()
                }
            }
        } else {
            startSocket()
        }
    }
    
    // Attempts to connect to the websocket
    private func startSocket() {
        progressLabel.text = "Connecting Socket"
        
        Socket.shared.start { [weak self] _ in
            self?.progressLabel.text = "Connected"
            
            Threading.run(on: .main, after: 0.3) { [weak self] in
                self?.performSegue(withIdentifier: "EnterApp", sender: nil)
            }
        }
    }
    
    // MARK: - Helper
    
    private func needsUpdate(version: String) -> Bool {
        guard let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return false }
        return current.compare(version, options: .numeric) == .orderedAscending
    }

    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
