//
//  SettingsListSwitchCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 06/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class SettingsListSwitchCell: UITableViewCell {

    @IBOutlet var primaryLabel: TTTAttributedLabel!
    @IBOutlet var secondaryLabel: UILabel!
    var callback: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        primaryLabel.kern = 1.8
    }
    
    func setText(_ primary: String, _ secondary: String) {
        primaryLabel.setText(primary.uppercased())
        secondaryLabel.text = secondary
    }
    
    @IBAction func didPressSwitch(_ sender: UISwitch) {
        UIView.animate(withDuration: 0.2) {
            self.primaryLabel.alpha = sender.isOn ? 1 : 0.3
            self.secondaryLabel.alpha = sender.isOn ? 1 : 0.3
        }
        
        callback?(sender.isOn)
    }
}
