//
//  UserModalViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 15/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke

class UserModalViewController: UIViewController {

    @IBOutlet var moderateButton: UIButton!
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var robotCountLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var detailsContainerView: UIView!
    @IBOutlet var loadingContainerView: UIView!
    
    var user: User!
    
    /// The robot in which the modal was launched from
    var robot: Robot?
    
    class func create() -> UserModalViewController {
        let storyboard = UIStoryboard(name: "Modals", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "UserModal") as? UserModalViewController else {
            fatalError()
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsContainerView.alpha = 0
        
        thumbnailImageView.layer.borderColor = UIColor.white.cgColor
        thumbnailImageView.layer.borderWidth = 1
        
        if user.downloaded == true {
            showDetailsPane()
        } else {
            user.loadPublic { [weak self] error in
                guard error == nil else {
                    self?.loadingLabel.text = "Something went wrong!"
                    self?.loadingIndicator.stopAnimating()
                    return
                }
                
                self?.showDetailsPane()
            }
        }
        
        if let user = User.current {
            let role = user.role(for: robot)
            
            switch role {
            case .staff, .globalModerator, .moderator:
                return
            default:
                moderateButton.isHidden = true
            }
        } else {
            moderateButton.isHidden = true
        }
    }
    
    func showDetailsPane() {
        UIView.animate(withDuration: 0.3) {
            self.loadingContainerView.alpha = 0
            self.detailsContainerView.alpha = 1
        }
        
        nameLabel.text = user.username
        descriptionLabel.text = user.description ?? "No User Description"
        robotCountLabel.text = String(user.publicRobots.count)
        
        if let url = user.avatarUrl {
            Nuke.loadImage(with: url, into: thumbnailImageView)
        }
    }
    
    @IBAction func didPressViewUser() {
        
    }
    
    @IBAction func didPressModerateUser() {
        guard let modal = ModerateModalViewController.createModal(for: user, robot: robot) else { return }
        present(modal, animated: true, completion: nil)
    }
}
