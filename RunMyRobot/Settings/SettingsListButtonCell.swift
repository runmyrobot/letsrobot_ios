//
//  SettingsListButtonCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 11/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class SettingsListButtonCell: UITableViewCell {

    @IBOutlet var primaryButton: UIButton!
    var callback: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
    }
    
    func setInfo(_ cellInfo: [String: Any]) {
        primaryButton.setTitle(cellInfo["title"] as? String, for: .normal)
        
        if let callback = cellInfo["callback"] as? (() -> Void) {
            self.callback = callback
        }
    }
    
    @IBAction func didPressButton() {
        callback?()
    }
}
