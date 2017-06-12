//
//  SendScreenshotViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 11/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import GSMessages

class SendScreenshotViewController: UIViewController {

    @IBOutlet var sendButton: UIButton!
    @IBOutlet var sendIndicator: UIActivityIndicatorView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var captionTextField: UITextField!
    @IBOutlet var previewImageView: UIImageView!
    
    var robot: Robot!
    var image: UIImage?
    weak var messageViewController: UIViewController?
    
    class func create() -> SendScreenshotViewController {
        let storyboard = UIStoryboard(name: "Modals", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SendScreenshot") as? SendScreenshotViewController else {
            fatalError()
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewImageView.image = image
        descriptionLabel.text = "Share this picture of \(robot.name) with other users!"
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
        guard let image = image else { return }
        
        sendButton.setTitle(nil, for: .normal)
        sendIndicator.startAnimating()
        
        robot.sendScreenshot(image, caption: captionTextField.text) { error in
            self.dismiss(animated: true) {
                if error != nil {
                    self.messageViewController?.showMessage("Something went wrong", type: .error)
                } else {
                    self.messageViewController?.showMessage("Screenshot has been sent!", type: .success)
                }
            }
        }
    }
}
