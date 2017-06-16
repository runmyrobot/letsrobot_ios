//
//  SnapshotPreviewCollectionViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 15/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import PopupDialog
import Nuke

class SnapshotPreviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var previewImageView: UIImageView!
    
    var snapshot: Snapshot!
    weak var parentViewController: UIViewController?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
    }
    
    func setup(_ snapshot: Snapshot) {
        self.snapshot = snapshot
        
        if let url = snapshot.image {
            Nuke.loadImage(with: url, into: previewImageView)
        }
    }
    
    @IBAction func didPressImage() {
        let modal = PreviewScreenshotViewController.create()
        modal.snapshot = snapshot
        
        let popup = PopupDialog(viewController: modal, transitionStyle: .zoomIn)
        parentViewController?.present(popup, animated: true, completion: nil)
    }
    
}
