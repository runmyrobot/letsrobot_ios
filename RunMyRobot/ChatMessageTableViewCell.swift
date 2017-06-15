//
//  ChatMessageTableViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 02/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import PopupDialog

class ChatMessageTableViewCell: UITableViewCell {
    
    @IBOutlet var messageLabel: TTTAttributedLabel!
    weak var parentViewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.delegate = self
    }
    
    func setNewMessage(_ message: ChatMessage) {
        let attString = NSMutableAttributedString()
        
        if let userMessage = message as? UserChatMessage {
            let username = NSAttributedString(string: "\(userMessage.name): ", attributes: [
                NSForegroundColorAttributeName: userMessage.color,
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
            ])
            
            let robot = NSAttributedString(string: "[\(userMessage.robotName)] ", attributes: [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: userMessage.robot == nil ? UIFontWeightMedium : UIFontWeightSemibold)
            ])
            
            let text = NSAttributedString(string: userMessage.message, attributes: [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
            ])
            
            attString.append(username)
            attString.append(robot)
            attString.append(text)
        } else {
            let text = NSAttributedString(string: message.description, attributes: [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
            ])
            
            attString.append(text)
        }
        
        messageLabel.setText(attString)
        messageLabel.linkAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleNone.rawValue
        ]
        
        messageLabel.activeLinkAttributes = [
            NSForegroundColorAttributeName: UIColor(hex: "#cccccc"),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleNone.rawValue
        ]
        
        if let userMessage = message as? UserChatMessage {
            let rawString = messageLabel.attributedText.string
            let rawNSString = rawString as NSString
            
            let robotRange = rawNSString.range(of: "[\(userMessage.robotName)]")
            if robotRange.location != NSNotFound, let url = URL(string: "letsrobot://robot/\(userMessage.robotName)") {
                messageLabel.addLink(to: url, with: robotRange)
            }
            
            let senderRange = rawNSString.range(of: "\(userMessage.name):")
            if senderRange.location != NSNotFound, !userMessage.anonymous, let url = URL(string: "letsrobot://user/\(userMessage.name)") {
                messageLabel.addLink(with: NSTextCheckingResult.linkCheckingResult(range: senderRange, url: url), attributes: [
                    NSForegroundColorAttributeName: userMessage.color,
                    NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
                ])
            }
            
            let matches = rawString.rangesMatching(pattern: "\\@(\\w+)")
            for match in matches {
                guard let nameMatch = match.first else { continue }
                let name = rawNSString.substring(with: nameMatch)
                guard let user = User.get(name: name) else { continue }
                guard !user.username.hasPrefix("anon") else { continue }
                guard let url = URL(string: "letsrobot://user/\(name)") else { continue }
                
                messageLabel.addLink(with: NSTextCheckingResult.linkCheckingResult(range: nameMatch, url: url), attributes: [
                    NSForegroundColorAttributeName: UIColor.white,
                    NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
                ])
            }
        }
    }
}

extension ChatMessageTableViewCell: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        print("Pressed URL! \(url.absoluteString)")
        
        let components = url.absoluteString.components(separatedBy: "/")
        guard components.first == "letsrobot:" else { return }
        
        if components.count == 4, components[2] == "robot" {
            let robotName = components[3]
            guard let robot = Robot.get(name: robotName) else { return }
            
            let modal = RobotModalViewController.create()
            modal.robot = robot
            
            let popup = PopupDialog(viewController: modal, transitionStyle: .zoomIn)
            parentViewController?.present(popup, animated: true, completion: nil)
        } else if components.count == 4, components[2] == "user" {
            let userName = components[3]
            guard let user = User.get(name: userName) else { return }
            
            let modal = UserModalViewController.create()
            modal.user = user
            
            let popup = PopupDialog(viewController: modal, transitionStyle: .zoomIn)
            parentViewController?.present(popup, animated: true, completion: nil)
        }
    }
    
}
