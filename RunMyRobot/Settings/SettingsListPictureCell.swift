//
//  SettingsListPictureCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 10/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke

class SettingsListPictureCell: UITableViewCell {

    @IBOutlet var primaryButton: UIButton!
    @IBOutlet var imagePreviewView: UIImageView!
    var callback: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .clear
        
        imagePreviewView.layer.borderColor = UIColor.white.cgColor
        imagePreviewView.layer.borderWidth = 1
    }
    
    func setButton(_ title: String, _ image: URL?) {
        primaryButton.setTitle(title, for: .normal)
        
        if let image = image {
            Nuke.loadImage(with: image, into: imagePreviewView)
        }
    }
    
    @IBAction func didPressButton() {
        callback?()
    }
}
