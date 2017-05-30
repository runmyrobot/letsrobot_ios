//
//  RobotTableViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 29/05/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke

class RobotTableViewCell: UITableViewCell {

    @IBOutlet var onlineContainerView: UIView!
    @IBOutlet var nameToOnlineConstraint: NSLayoutConstraint!
    @IBOutlet var robotThumbnailImageView: UIImageView!
    @IBOutlet var robotNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setRobot(_ robot: Robot) {
        setOnline(robot.live)
        robotNameLabel.text = robot.name
        robotThumbnailImageView.image = nil
        
        if let imageURL = URL(string: robot.avatarUrl) {
            Nuke.loadImage(with: imageURL, into: robotThumbnailImageView)
        }
    }
    
    func setOnline(_ value: Bool) {
        nameToOnlineConstraint.isActive = value
        onlineContainerView.isHidden = !value
    }

}
