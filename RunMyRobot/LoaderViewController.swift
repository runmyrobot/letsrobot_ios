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

class LoaderViewController: UIViewController {

    @IBOutlet var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        progressLabel.text = "Downloading Config"
        Alamofire.request("https://runmyrobot.com/internal/").validate().responseJSON { [weak self] response in
            guard let rawJSON = response.result.value else {
                self?.progressLabel.text = "Error Downloading Config"
                print("Something went wrong!")
                return
            }
            
            self?.progressLabel.text = "Converting Config"
            let config = Config(json: JSON(rawJSON))
            Config.shared = config
            
            self?.progressLabel.text = "Connecting Socket"
            Socket.shared.start { [weak self] success in
                self?.progressLabel.text = "Connected"
                
                Threading.run(on: .main, after: 0.3) { [weak self] in
                    self?.performSegue(withIdentifier: "EnterApp", sender: nil)
                }
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
