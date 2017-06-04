//
//  StreamViewController+Actions.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Nuke
import Popover

extension StreamViewController {
    
    @IBAction func didPressBack() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressSubscribe() {
        
    }
    
    @IBAction func didPressViewerCount() {
        
    }
    
    @IBAction func didPressShare(_ sender: UIButton) {
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
        }, completion: { success in
            if desiredView == 1 {
                self.controlContainerView.isHidden = true
            } else {
                self.chatTableView.isHidden = true
            }
        })
    }
    
    @IBAction func didPressMessageSend(_ sender: UITextField) {
        guard let message = sender.text else { return }
        try? Socket.shared.chat(message, robot: robot)
        
        // Clear the field
        sender.text = nil
    }
    
    @IBAction func didPressDirection(_ sender: UIButton) {
        guard let direction = command(from: sender.tag) else { return }
        
        // Setup a timer which will be used to send out continous direction requests via the socket
        // This allows the user to hold down a direction and continue moving
        touchDownDirection = direction
        touchDownTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(didHoldDirection), userInfo: nil, repeats: true)
        
        try? Socket.shared.sendDirection(direction, robot: robot, keyPosition: "down")
    }
    
    @IBAction func didReleaseDirection(_ sender: UIButton) {
        guard let direction = command(from: sender.tag) else { return }
        
        // Clean up the timer and cancel any future runs
        touchDownTimer?.invalidate()
        touchDownTimer = nil
        touchDownDirection = nil
        
        try? Socket.shared.sendDirection(direction, robot: robot, keyPosition: "up")
    }
    
    func didHoldDirection() {
        guard let direction = touchDownDirection else { return }
        try? Socket.shared.sendDirection(direction, robot: robot, keyPosition: "down")
    }
    
    func didTapCamera() {
        setCameraControlsVisible(!controlsVisible)
    }
    
    func didHoldChatButton(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        settingsView = ChatSettingsView.createView()
        settingsView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140)
        settingsView?.delegate = self
        settingsView?.chatFilterControl.selectedSegmentIndex = chatFilterMode
        settingsView?.profanityFilterSwitch.isOn = profanityFilterEnabled
        
        let popover = Popover(options: [
            .type(.up),
            .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
            .cornerRadius(0)
        ])
        
        popover.willShowHandler = {
            self.settingsView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 140)
        }
        
        if let settingsView = settingsView {
            popover.show(settingsView, fromView: chatPageButton)
        }
    }
}
