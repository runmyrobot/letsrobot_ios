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
    var callback: ((String?) -> Void)?
    var required = false
    
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
        
        textField.delegate = self
    }
    
    deinit {
        textField.delegate = nil
    }
    
    func setInfo(_ cellInfo: [String: Any]) {
        guard let primary = cellInfo["title"] as? String,
              let secondary = cellInfo["subtitle"] as? String,
              let keyboardType = cellInfo["keyboard"] as? String,
              let placeholder = cellInfo["placeholder"] as? String else { return }
        
        primaryLabel.setText(primary.uppercased())
        secondaryLabel.text = secondary
        
        if let required = cellInfo["required"] as? Bool {
            self.required = required
        }
        
        if let callback = cellInfo["callback"] as? ((String?) -> Void) {
            self.callback = callback
        }
        
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

extension SettingsListTextFieldCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if required, text == "" {
            return
        }
        
        callback?(text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
