//
//  StreamViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 31/05/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class StreamViewController: UIViewController {

    @IBOutlet var chatTextField: UITextField!
    @IBOutlet var chatTableView: UITableView!
    @IBOutlet var gameIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var chatBoxTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var viewSwapperBottomConstraint: NSLayoutConstraint!
    
    /// Current robot, as set from the Robot Chooser segue
    var robot: Robot!
    
    /// The current view shown to the user: 1 is Chat, 2 is Controls
    var activeView: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTextField.attributedPlaceholder = NSAttributedString(string: "Type your text here...", attributes: [
            NSForegroundColorAttributeName: UIColor.white
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func didPressChangeView(_ sender: UIButton) {
        let desiredView = sender.tag
        guard activeView != desiredView else { return }
        
        view.endEditing(true)
        activeView = desiredView
        
        chatBoxTrailingConstraint.isActive = desiredView == 1
        gameIconTrailingConstraint.isActive = desiredView == 1
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func didPressMessageSend(_ sender: UITextField) {
        guard let message = sender.text else { return }
        print("Send Message:", message)
        
        // Clear the field
        sender.text = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Notifications
    
    func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animation = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIViewAnimationOptions(rawValue: animation)
        
        if endFrame.origin.y >= UIScreen.main.bounds.size.height {
            viewSwapperBottomConstraint.constant = 0
        } else {
            viewSwapperBottomConstraint.constant = endFrame.size.height
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

}

extension StreamViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ChatMessage", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
