//
//  RobotTableViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 29/05/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke
import UIImageColors

class RobotTableViewCell: UITableViewCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var angledOverlayView: AngledView!
    @IBOutlet var colorOverlayView: UIView!
    @IBOutlet var onlineContainerView: UIView!
    @IBOutlet var robotThumbnailImageView: UIImageView!
    @IBOutlet var robotNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.6
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setRobot(_ robot: Robot) {
        onlineContainerView.isHidden = !robot.live
        robotNameLabel.text = robot.name.uppercased()
        robotThumbnailImageView.image = nil
        
        if let imageURL = URL(string: robot.avatarUrl) {
            Nuke.loadImage(with: imageURL, into: robotThumbnailImageView) { (result, isFromCache) in
                self.robotThumbnailImageView.image = result.value
                
                result.value?.getColors { colors in
                    self.colorOverlayView.backgroundColor = colors.backgroundColor
                    self.angledOverlayView.shadowColor = colors.primaryColor.withAlphaComponent(0.6)
                    self.angledOverlayView.angleColor = colors.backgroundColor
                    self.robotNameLabel.textColor = colors.primaryColor
                }
            }
        }
    }

}
