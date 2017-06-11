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

    @IBOutlet var toggleSwitch: UISwitch!
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
    
    func setState(_ enabled: Bool) {
        primaryLabel.alpha = enabled ? 0.8 : 0.3
        secondaryLabel.alpha = enabled ? 0.8 : 0.3
    }
    
    @IBAction func didPressSwitch(_ sender: UISwitch) {
        UIView.animate(withDuration: 0.2) {
            self.setState(sender.isOn)
        }
        
        callback?(sender.isOn)
    }
}
