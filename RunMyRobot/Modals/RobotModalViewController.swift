//
//  RobotModalViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 14/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke

class RobotModalViewController: UIViewController {

    @IBOutlet var ownerLabel: UILabel!
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var subscriberCountLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var detailsContainerView: UIView!
    @IBOutlet var loadingContainerView: UIView!
    
    var robot: Robot!
    
    class func create() -> RobotModalViewController {
        let storyboard = UIStoryboard(name: "Modals", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "RobotModal") as? RobotModalViewController else {
            fatalError()
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailsContainerView.alpha = 0
        
        thumbnailImageView.layer.borderColor = UIColor.white.cgColor
        thumbnailImageView.layer.borderWidth = 1
        
        if robot.downloaded == true {
            showDetailsPane()
        } else {
            robot.download { [weak self] success in
                if success {
                    self?.showDetailsPane()
                } else {
                    self?.loadingLabel.text = "Something went wrong!"
                    self?.loadingIndicator.stopAnimating()
                }
            }
        }
    }
    
    func showDetailsPane() {
        UIView.animate(withDuration: 0.3) {
            self.loadingContainerView.alpha = 0
            self.detailsContainerView.alpha = 1
        }
        
        nameLabel.text = robot.name
        descriptionLabel.text = robot.description ?? "No Robot Description"
        subscriberCountLabel.text = String(robot.subscribers?.count ?? 0)
        
        if let owner = robot.owner {
            ownerLabel.text = "Owner: \(owner)"
        } else {
            ownerLabel.text = "Unknown Owner"
        }
        
        if let url = robot.avatarUrl {
            Nuke.loadImage(with: url, into: thumbnailImageView)
        }
    }
    
    @IBAction func didPressViewRobot() {
        
    }
}
