//
//  MenuListItemCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 07/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class MenuListItemCell: UITableViewCell {

    @IBOutlet var itemLabel: TTTAttributedLabel!
    @IBOutlet var iconImageView: UIImageView!
    
    func configure(title: String, image: String) {
        itemLabel.setText(title.uppercased())
        iconImageView.image = UIImage(named: image)
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.15)
    }

}
