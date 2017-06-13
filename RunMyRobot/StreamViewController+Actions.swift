//
//  StreamViewController+Actions.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke
import Crashlytics

extension StreamViewController {
    
    @IBAction func didPressBack() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressSubscribe() {
        guard let user = User.current else { return }
        
        let robotId = robot.id
        subscribeButton.setTitle(nil, for: .normal)
        subscribeIndicator.startAnimating()
        
        let isSubscribed = user.isSubscribed(to: robotId)
        user.subscribe(!isSubscribed, robotId: robotId) { error in
            if let error = error as? RobotError {
                print("\(error)")
                return
            }
            
            self.subscribeIndicator.stopAnimating()
            
            if user.isSubscribed(to: robotId) {
                self.subscribeButton.setTitle("unsubscribe", for: .normal)
            } else {
                self.subscribeButton.setTitle("subscribe", for: .normal)
            }
            
            self.subscriberCountLabel.text = String(self.robot.subscribers?.count ?? 0)
        }
    }
    
    @IBAction func didPressViewerCount() {
        
    }
    
    @IBAction func didPressShare(_ sender: UIButton) {
        sendScreenshot()
        return
        var url = StreamViewControllerHelper.Sharing.url
        var message = StreamViewControllerHelper.Sharing.message
        
        let templates = [
            ("{robotid}", robot.id),
            ("{robotname}", robot.name)
        ]
        
        url.replaceTemplatesInString(templates)
        message.replaceTemplatesInString(templates)
        
        guard let website = URL(string: url) else { return }
        var activityItems: [Any] = [message, website]
        
        if let avatarUrl = robot.avatarUrl {
            let key = Request.cacheKey(for: Request(url: avatarUrl))
            if let image = Manager.shared.cache?[key] {
                activityItems.append(image)
            }
        }
        
        let activity = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = sender
        activity.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            guard let activityType = activityType, completed else {
                return
            }
            
            Answers.logShare(withMethod: activityType.rawValue, contentName: "robot", contentType: "share", contentId: self.robot.id)
        }
        
        present(activity, animated: true, completion: nil)
    }
    
    @IBAction func didPressChangeView(_ sender: UIButton) {
        let desiredView = sender.tag
        guard activeView != desiredView else { return }
        
        view.endEditing(true)
        activeView = desiredView
        
        chatBoxTrailingConstraint.isActive = desiredView == 1
        gameIconTrailingConstraint.isActive = desiredView == 1
        
        controlContainerView.isHidden = false
        chatTableView.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            if desiredView == 1 {
                self.controlContainerView.isHidden = true
            } else {
                self.chatTableView.isHidden = true
            }
        })
    }
    
    @IBAction func didPressMessageSend(_ sender: UITextField) {
        guard let message = sender.text else { return }
        Socket.shared.chat.sendMessage(message, robot: robot)
        
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
    
    func didTapCamera() {
        setCameraControlsVisible(!controlsVisible)
    }
}
