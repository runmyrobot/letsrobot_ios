//
//  ChatMessageTableViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 02/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import PopupDialog

class ChatMessageTableViewCell: UITableViewCell {
    
    @IBOutlet var messageLabel: UILinkLabel!
    weak var parentViewController: UIViewController?
    weak var robot: Robot?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.delegate = self
    }
    
    // This function is way too complex, really aught to refactor it...
    func setNewMessage(_ message: ChatMessage) {
        let attString = NSMutableAttributedString()
        
        if let userMessage = message as? UserChatMessage {
            let badge: NSAttributedString? = {
                let badgeAttachment = NSTextAttachment()
                
                guard let role = userMessage.user?.role(for: userMessage.robot) else { return nil }
                
                let image: UIImage? = {
                    switch role {
                    case .staff:
                        return UIImage(named: "Chat/Staff")
                    case .globalModerator:
                        return UIImage(named: "Chat/GlobalMod")
                    case .owner:
                        return UIImage(named: "Chat/Owner")
                    case .moderator:
                        return UIImage(named: "Chat/Mod")
                    default:
                        return nil
                    }
                }()
                
                if image == nil {
                    return nil
                }
                
                badgeAttachment.image = image
                badgeAttachment.bounds = CGRect(x: 0, y: -4, width: 20, height: 20)
                
                return NSAttributedString(attachment: badgeAttachment)
            }()
            
            let spacing = badge != nil ? "  " : ""
            
            let username = NSAttributedString(string: "\(spacing)\(userMessage.name): ", attributes: [
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
            
            if let badge = badge {
                attString.append(badge)
            }
            
            attString.append(username)
            attString.append(robot)
            attString.append(text)
        } else if let snapshotMessage = message as? SnapshotMessage {
            let user = User.get(name: snapshotMessage.snapshot.sender)
            
//            let cameraAttachment = NSTextAttachment()
//            let image = UIImage(named: "icon-camera")
//            cameraAttachment.image = image
//            cameraAttachment.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
//            
//            let camera = NSAttributedString(attachment: cameraAttachment)
            
            let username = NSAttributedString(string: "\(user?.username ?? snapshotMessage.snapshot.sender)", attributes: [
                NSForegroundColorAttributeName: user?.usernameColor ?? UIColor(hex: "#636363"),
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
            ])
            
            let textRaw = " submitted a new screenshot of \(snapshotMessage.snapshot.robotName ?? "Unknown")!"
            let text = NSAttributedString(string: textRaw, attributes: [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
            ])
            
            let prompt = NSAttributedString(string: " (Tap to open)", attributes: [
                NSForegroundColorAttributeName: UIColor(hex: "#949494"),
                NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
            ])
            
//            attString.append(camera)
            attString.append(username)
            attString.append(text)
            attString.append(prompt)
        } else {
            let text = NSAttributedString(string: message.description, attributes: [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
            ])
            
            attString.append(text)
        }
        
        messageLabel.setLinkText(attString)
        
        messageLabel.linkAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleNone.rawValue
        ]
        
        let rawString = messageLabel.attributedText?.string ?? ""
        let rawNSString = rawString as NSString
        let rangeOfEntireString = NSRange(location: 0, length: rawNSString.length)
        
        if let userMessage = message as? UserChatMessage {
            let robotRange = rawNSString.range(of: "[\(userMessage.robotName)]")
            if robotRange.location != NSNotFound, let url = URL(string: "letsrobot://robot/\(userMessage.robotName)") {
                messageLabel.addLink(to: url, at: robotRange)
            }
            
            let senderRange = rawNSString.range(of: "\(userMessage.name):")
            if senderRange.location != NSNotFound, !userMessage.anonymous, let url = URL(string: "letsrobot://user/\(userMessage.name)") {
                messageLabel.addLink(to: url, at: senderRange, attributes: [
                    NSForegroundColorAttributeName: userMessage.color,
                    NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
                ])
            }
            
            let matches = rawString.rangesMatching(pattern: "\\@(\\w+)")
            for match in matches {
                guard let nameMatch = match.first else { continue }
                let name = rawNSString.substring(with: nameMatch)
                guard let user = User.get(name: name) else { continue }
                guard !user.anonymous else { continue }
                guard let url = URL(string: "letsrobot://user/\(name)") else { continue }
                
                messageLabel.addLink(to: url, at: nameMatch, attributes: [
                    NSForegroundColorAttributeName: UIColor.white,
                    NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
                ])
            }
        } else if let snapshotMessage = message as? SnapshotMessage,
                  let url = URL(string: "letsrobot://snapshot/\(snapshotMessage.snapshot.id)") {
            
            attString.enumerateAttribute(NSForegroundColorAttributeName, in: rangeOfEntireString, options: .init(rawValue: 0), using: { (value, range, _) in
                
                messageLabel.addLink(to: url, at: range, attributes: [
                    NSForegroundColorAttributeName: value as? UIColor ?? UIColor.white
                ])
            })
        }
    }
}

extension ChatMessageTableViewCell: UILinkLabelDelegate {
    
    func attributedLabel(_ label: UILinkLabel!, didSelectLinkWith url: URL!) {
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
            modal.robot = robot
            
            let popup = PopupDialog(viewController: modal, transitionStyle: .zoomIn)
            parentViewController?.present(popup, animated: true, completion: nil)
        } else if components.count == 4, components[2] == "snapshot" {
            let snapshotId = components[3]
            guard let snapshot = Snapshot.all[snapshotId] else { return }
            
            let modal = PreviewScreenshotViewController.create()
            modal.snapshot = snapshot
            
            let popup = PopupDialog(viewController: modal, transitionStyle: .zoomIn)
            parentViewController?.present(popup, animated: true, completion: nil)
        }
    }
    
}
