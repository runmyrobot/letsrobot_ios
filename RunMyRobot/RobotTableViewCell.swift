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
//    @IBOutlet var onlineContainerView: UIView!
    @IBOutlet var robotThumbnailImageView: UIImageView!
    @IBOutlet var robotNameLabel: UILabel!
    @IBOutlet var loadingActivityIndicator: UIActivityIndicatorView!
    
    var robotId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOpacity = 0.4
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        colorOverlayView.backgroundColor = colorOverlayView.tintColor
        angledOverlayView.shadowColor = .white
        angledOverlayView.angleColor = colorOverlayView.tintColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setFocussed(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        setFocussed(highlighted, animated: animated)
    }
    
    func setFocussed(_ focussed: Bool, animated: Bool) {
        guard let robotId = robotId else { return }
        let robot = Config.shared?.robots[robotId]
        guard let colors = robot?.colors else { return }
        
        if !focussed {
            self.setColors(colors)
        } else {
            let color = colors.backgroundColor.darker(by: 10)
            self.angledOverlayView.angleColor = color
            self.colorOverlayView.backgroundColor = color
        }
    }
    
    func setRobot(_ robot: Robot) {
        robotId = robot.id
//        onlineContainerView.isHidden = !robot.live
        robotNameLabel.text = robot.name.uppercased()
        robotThumbnailImageView.image = nil
        
        if let imageURL = robot.avatarUrl {
            loadingActivityIndicator.startAnimating()
            Nuke.loadImage(with: imageURL, into: robotThumbnailImageView) { (result, isFromCache) in
                if let colors = robot.colors {
                    self.robotThumbnailImageView.image = result.value
                    self.setColors(colors)
                    self.loadingActivityIndicator.stopAnimating()
                } else {
                    result.value?.getColors(scaleDownSize: CGSize(width: 100, height: 100)) { colors in
                        Config.shared?.robots[robot.id]?.colors = colors
                        self.robotThumbnailImageView.image = result.value
                        self.setColors(colors)
                        self.loadingActivityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    func setColors(_ colors: UIImageColors) {
        colorOverlayView.backgroundColor = colors.backgroundColor.darker(by: 5)
        angledOverlayView.shadowColor = colors.primaryColor.withAlphaComponent(0.6)
        angledOverlayView.angleColor = colors.backgroundColor.darker(by: 5)
        robotNameLabel.textColor = colors.primaryColor
    }

}
