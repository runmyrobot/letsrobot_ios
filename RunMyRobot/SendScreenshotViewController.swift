//
//  SendScreenshotViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 11/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class SendScreenshotViewController: UIViewController {

    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var captionTextField: UITextField!
    @IBOutlet var previewImageView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewImageView.image = image
        
        setupTextField()
    }
    
    func setupTextField() {
        captionTextField.borderStyle = .line
        captionTextField.layer.borderColor = UIColor.white.cgColor
        captionTextField.layer.borderWidth = 1
        captionTextField.layer.cornerRadius = 4
        captionTextField.leftViewMode = .always
        captionTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 20))
    }

    @IBAction func didPressSend() {
        dismiss(animated: true, completion: nil)
    }
}
