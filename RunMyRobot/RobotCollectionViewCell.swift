//
//  RobotCollectionViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 01/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke
import UIImageColors

class RobotCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var robotThumbnailImageView: UIImageView!
    @IBOutlet var robotNameLabel: UILabel!
    
    @IBOutlet var angledOverlayView: AngledView!
    @IBOutlet var colorOverlayView: UIView!
    
    @IBOutlet var liveIndicator: UIView!
    @IBOutlet var loadingActivityIndicator: UIActivityIndicatorView!
    
    var robotId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        liveIndicator.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        liveIndicator.layer.borderWidth = 1
    }

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
    }
    
    func setRobot(_ robot: Robot) {
        robotId = robot.id
        
        liveIndicator.isHidden = !robot.live
        robotNameLabel.text = robot.name.uppercased()
        robotThumbnailImageView.image = nil
        
        if let imageURL = robot.avatarUrl {
            loadingActivityIndicator.startAnimating()
            Nuke.loadImage(with: imageURL, into: robotThumbnailImageView) { (result, isFromCache) in
                if let error = result.error {
                    print(error.localizedDescription)
                    self.loadingActivityIndicator.stopAnimating()
                }
                
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

extension UIColor {
    
    func lighter(by percentage: CGFloat) -> UIColor {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat) -> UIColor {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    private func adjust(by percentage: CGFloat) -> UIColor {
        var r: CGFloat = 0,
        g: CGFloat = 0,
        b: CGFloat = 0,
        a: CGFloat = 0
        
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }
        
        return self
    }
}
