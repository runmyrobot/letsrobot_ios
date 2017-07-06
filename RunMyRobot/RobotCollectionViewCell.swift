//
//  RobotCollectionViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 01/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke
import UIImageColors

class RobotCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var ownerNameLabel: UILabel!
    @IBOutlet var robotThumbnailImageView: UIImageView!
    @IBOutlet var robotNameLabel: UILabel!
    
    @IBOutlet var angledOverlayView: AngledView!
    @IBOutlet var colorOverlayView: UIView!
    
    @IBOutlet var loadingActivityIndicator: UIActivityIndicatorView!
    
    var robotId: String?

    override var isSelected: Bool {
        didSet {
            setFocussed(isSelected)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            setFocussed(isHighlighted)
        }
    }
    
    func setFocussed(_ focussed: Bool) {
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        colorOverlayView.backgroundColor = colorOverlayView.tintColor
        angledOverlayView.shadowColor = .white
        angledOverlayView.angleColor = colorOverlayView.tintColor
        robotNameLabel.textColor = .white
        ownerNameLabel.textColor = .white
    }
    
    func setRobot(_ robot: Robot) {
        robotId = robot.id
        
        robotNameLabel.text = robot.name.uppercased()
        robotThumbnailImageView.image = nil
        alpha = robot.live ? 1 : 0.7
        ownerNameLabel.text = "Owner: \(robot.owner ?? "Unknown")"
        
        if let imageURL = robot.avatarUrl {
            loadingActivityIndicator.startAnimating()
            Nuke.loadImage(with: imageURL, into: robotThumbnailImageView) { (result, _) in
                if let error = result.error {
                    print(error.localizedDescription)
                    self.loadingActivityIndicator.stopAnimating()
                }
                
                if !self.loadColours() {
                    self.robotThumbnailImageView.image = result.value
                    self.loadingActivityIndicator.stopAnimating()
                } else if let colors = robot.colors {
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
        ownerNameLabel.textColor = colors.primaryColor
    }
    
    func loadColours() -> Bool {
        return Device.Size.current != .iPhone4
    }
}
