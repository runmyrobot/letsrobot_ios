//
//  SettingsListTitleCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 10/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class SettingsListTitleCell: UITableViewCell {

    @IBOutlet var sectionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
    }

    func setInfo(_ cellInfo: [String: Any]) {
        sectionTitleLabel.text = cellInfo["title"] as? String
    }
    
}
