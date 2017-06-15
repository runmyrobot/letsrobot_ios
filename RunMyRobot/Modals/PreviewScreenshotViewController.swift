//
//  PreviewScreenshotViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 15/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke

class PreviewScreenshotViewController: UIViewController {

    @IBOutlet var submittedLabel: UILabel!
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var previewImageView: UIImageView!
    
    var snapshot: Snapshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Snapshot of \(snapshot.robotName)"
        captionLabel.text = snapshot.caption
        submittedLabel.text = "Submitted by \(snapshot.sender)"
        
        if let url = snapshot.image {
            Nuke.loadImage(with: url, into: previewImageView)
        }
    }
    
    @IBAction func didPressVisitRobot() {
        guard let robot = Robot.get(name: snapshot.robotName) else { return }
        print("Show \(robot.name)")
    }
}
