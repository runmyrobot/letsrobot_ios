//
//  RobotProfileViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 15/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke
import Crashlytics

class RobotProfileViewController: UIViewController {

    @IBOutlet var snapshotIndicator: UIActivityIndicatorView!
    @IBOutlet var snapshotLabel: UILabel!
    @IBOutlet var snapshotCollectionView: UICollectionView!
    @IBOutlet var lastActivityLabel: UILabel!
    @IBOutlet var robotDescriptionLabel: UILabel!
    @IBOutlet var robotTitleLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    
    var robot: Robot!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        robotTitleLabel.text = robot.name
        robotDescriptionLabel.text = robot.description ?? "This robot has no description!"
        
        if let url = robot.avatarUrl {
            Nuke.loadImage(with: url, into: profileImageView)
        }
        
        if robot.snapshotsFetched == false {
            robot.fetchSnapshots { [weak self] error in
                if error != nil {
                    self?.snapshotLabel.text = "Failed to load snapshots"
                    return
                }
                
                self?.snapshotIndicator.stopAnimating()
                self?.snapshotLabel.isHidden = true
                self?.snapshotCollectionView.reloadData()
            }
        } else {
            snapshotIndicator.stopAnimating()
            snapshotLabel.isHidden = true
        }
        
        if robot.live {
            lastActivityLabel.text = "Last Activity: \(robot.name) is live!"
        } else if let date = robot.lastActivity {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d 'at' h:mma"
            
            let dateString = dateFormatter.string(from: date)
            lastActivityLabel.text = "Last Activity: \(dateString)"
        } else {
            lastActivityLabel.text = "Last Activity: Unknown"
        }
        
        Answers.logContentView(withName: "Viewed Robot Profile", contentType: "robot_profile", contentId: robot.id)
    }
    
    @IBAction func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension RobotProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if robot.snapshotsFetched, robot.snapshots.count == 0 {
            snapshotLabel.text = "No Snapshots Found"
            snapshotLabel.isHidden = false
        } else if robot.snapshots.count > 0 {
            snapshotLabel.isHidden = true
        }
        
        return min(robot.snapshots.count, 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Snapshot", for: indexPath) as? SnapshotPreviewCollectionViewCell else {
            fatalError()
        }
        
        cell.parentViewController = self
        cell.setup(robot.snapshots[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let aspectRatio = CGFloat(4) / CGFloat(3)
        let width = collectionView.frame.height * aspectRatio
        return CGSize(width: width, height: collectionView.frame.height)
    }
    
}
