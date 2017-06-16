//
//  RobotProfileViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 15/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke

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
        return robot.snapshots.count
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