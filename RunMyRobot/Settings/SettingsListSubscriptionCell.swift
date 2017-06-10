//
//  SettingsListSubscriptionCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 10/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class SettingsListSubscriptionCell: UITableViewCell {

    @IBOutlet var robotTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
    }

    func setInfo(_ cellInfo: [String: Any]) {
        robotTitleLabel.text = cellInfo["name"] as? String
    }
    
    @IBAction func didPressUnsubscribe() {
        
    }
}
