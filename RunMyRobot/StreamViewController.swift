//
//  StreamViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 31/05/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import ReverseExtension

class StreamViewController: UIViewController {

    // Camera
    @IBOutlet var cameraContainerView: UIView!
    @IBOutlet var cameraWebView: UIWebView!
    
    // Chat
    @IBOutlet var chatTextField: UITextField!
    @IBOutlet var chatTableView: UITableView!
    @IBOutlet var chatFilterControl: UISegmentedControl!
    
    // Constraints
    @IBOutlet var gameIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var chatBoxTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var viewSwapperBottomConstraint: NSLayoutConstraint!
    
    /// Timer used to send out continous socket messages when holding down a direction
    var touchDownTimer: Timer?
    
    /// Last direction touched down on, used in conjuction with the timer to send out continous socket messages.
    var touchDownDirection: RobotCommand?
    
    /// Current robot, as set from the Robot Chooser segue
    var robot: Robot!
    
    /// The current view shown to the user: 1 is Chat, 2 is Controls
    var activeView: Int = 1
    
    /// Returns an array of all the current chat messages to show, taking into account the chat filter control
    var chatMessages: [ChatMessage] {
        let allMessages = Socket.shared.chatMessages
        
        switch chatFilterControl.selectedSegmentIndex {
        case 1: return allMessages.filter { $0.robotName == robot.name }
        case 2: return allMessages
        default: return allMessages
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTextField.attributedPlaceholder = NSAttributedString(string: "Type your text here...", attributes: [
            NSForegroundColorAttributeName: UIColor.white
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        
        if let cameraURL = URL(string: "https://runmyrobot.com/fullview/\(robot.id)") {
            let request = URLRequest(url: cameraURL)
//            cameraWebView.scrollView.isScrollEnabled = false
            cameraWebView.loadRequest(request)
            cameraWebView.layoutIfNeeded()
        }
        
        chatTableView.re.delegate = self
        Socket.shared.chatCallback = chatUpdated
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        Socket.shared.chatCallback = nil
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
    
    @IBAction func didChangeChatFilter(_ sender: UISegmentedControl) {
        chatTableView.reloadData()
    }
    
    @IBAction func didPressMessageSend(_ sender: UITextField) {
        guard let message = sender.text else { return }
        Socket.shared.chat(message, robot: robot)
        
        // Clear the field
        sender.text = nil
    }
    
    @IBAction func didPressDirection(_ sender: UIButton) {
        guard let direction = command(from: sender.tag) else { return }
        
        // Setup a timer which will be used to send out continous direction requests via the socket
        // This allows the user to hold down a direction and continue moving
        touchDownDirection = direction
        touchDownTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(didHoldDirection), userInfo: nil, repeats: true)
        
        Socket.shared.sendDirection(direction, robot: robot, keyPosition: "down")
    }
    
    @IBAction func didReleaseDirection(_ sender: UIButton) {
        guard let direction = command(from: sender.tag) else { return }
        
        // Clean up the timer and cancel any future runs
        touchDownTimer?.invalidate()
        touchDownTimer = nil
        touchDownDirection = nil
        
        Socket.shared.sendDirection(direction, robot: robot, keyPosition: "up")
    }
    
    func didHoldDirection() {
        guard let direction = touchDownDirection else { return }
        Socket.shared.sendDirection(direction, robot: robot, keyPosition: "down")
    }
    
    func command(from tag: Int) -> RobotCommand? {
        switch tag {
        case 1: return .forward
        case 2: return .backward
        case 3: return .left
        case 4: return .right
        default: return nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func chatUpdated(message: ChatMessage) {
        chatTableView.beginUpdates()
        let count = chatMessages.count
        
        if count == 100 {
            chatTableView.re.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        chatTableView.re.insertRows(at: [IndexPath(row: count - 1, section: 0)], with: .automatic)
        chatTableView.endUpdates()
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
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessage", for: indexPath) as! ChatMessageTableViewCell
        
        let count = chatMessages.count - 1 - indexPath.row
        cell.setMessage(chatMessages[count])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
