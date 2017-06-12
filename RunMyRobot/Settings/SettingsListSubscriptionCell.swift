//
//  SettingsListSubscriptionCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 10/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class SettingsListSubscriptionCell: UITableViewCell {

    @IBOutlet var primaryButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var robotTitleLabel: UILabel!
    
    var robotId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
    }

    func setInfo(_ cellInfo: [String: Any]) {
        robotTitleLabel.text = cellInfo["name"] as? String
        robotId = cellInfo["robot_id"] as? String
    }
    
    @IBAction func didPressUnsubscribe() {
        guard let user = User.current else { return }
        guard let robotId = robotId else { return }
        
        primaryButton.setTitle(nil, for: .normal)
        activityIndicator.startAnimating()
        
        let isSubscribed = user.isSubscribed(to: robotId)
        user.subscribe(!isSubscribed, robotId: robotId) { error in
            if let error = error as? RobotError {
                print("\(error)")
                return
            }
            
            self.activityIndicator.stopAnimating()
            
            if user.isSubscribed(to: robotId) {
                self.primaryButton.setTitle("Unsubscribe", for: .normal)
            } else {
                self.primaryButton.setTitle("Subscribe", for: .normal)
            }
        }
    }
}
