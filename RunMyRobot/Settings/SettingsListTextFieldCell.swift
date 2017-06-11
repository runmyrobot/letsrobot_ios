//
//  SettingsListTextFieldCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 10/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class SettingsListTextFieldCell: UITableViewCell {

    @IBOutlet var textField: UITextField!
    @IBOutlet var primaryLabel: TTTAttributedLabel!
    @IBOutlet var secondaryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .clear
        primaryLabel.kern = 1.8
        
        textField.borderStyle = .line
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 4
        
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 20))
    }
    
    func setInfo(_ cellInfo: [String: Any]) {
        guard let primary = cellInfo["title"] as? String,
              let secondary = cellInfo["subtitle"] as? String,
              let keyboardType = cellInfo["keyboard"] as? String,
              let placeholder = cellInfo["placeholder"] as? String else { return }
        
        primaryLabel.setText(primary.uppercased())
        secondaryLabel.text = secondary
        
        if keyboardType == "phone" {
            textField.keyboardType = .phonePad
        } else {
            textField.keyboardType = .default
        }
        
        if let value = cellInfo["value"] as? String {
            textField.text = value
        }
        
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.6)
        ])
    }
    
}
