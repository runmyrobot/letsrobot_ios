//
//  ChatMessageTableViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 02/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ChatMessageTableViewCell: UITableViewCell {

    struct ChatColours {
        static let grey = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
        static let blue = UIColor(red: 33/255, green: 188/255, blue: 229/255, alpha: 1)
        static let green = UIColor(red: 151/255, green: 224/255, blue: 98/255, alpha: 1)
        static let yellow = UIColor(red: 243/255, green: 235/255, blue: 72/255, alpha: 1)
        static let purple = UIColor(red: 95/255, green: 121/255, blue: 255/255, alpha: 1)
        static let orange = UIColor(red: 249/255, green: 170/255, blue: 103/255, alpha: 1)
        static let pink = UIColor(red: 241/255, green: 107/255, blue: 116/255, alpha: 1)
        static let violet = UIColor(red: 166/255, green: 82/255, blue: 175/255, alpha: 1)
    }
    
    @IBOutlet var messageLabel: TTTAttributedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.delegate = self
    }
    
    func hash(name: NSString) -> Int {
        var hash: Int = 0
        
        for i in 0 ..< name.length {
            if i > 7 {
                return hash
            }
            
            let char = Int(name.character(at: i))
            hash = char + ((hash << 5) - hash)
        }
        
        return hash
    }
    
    func color(name: String) -> UIColor {
        let nameHash = hash(name: name as NSString)
        
        switch nameHash % 7 {
        case 0:
            return ChatColours.blue // 21BCE5
        case 1:
            return ChatColours.grey // 97E062
        case 2:
            return ChatColours.yellow // F3EB48
        case 3:
            return ChatColours.purple // 5F79FF
        case 4:
            return ChatColours.orange // F9AA67
        case 5:
            return ChatColours.pink // F16B74
        case 6:
            return ChatColours.violet // A652Af
        default:
            return ChatColours.blue // 21BCE5
        }
    }

    // v2
    
    func setNewMessage(_ message: ChatMessage) {
        
        // UserChatMessage
        // WootChatMessage
        // DefaultChatMessage - Mostly System Messages
        
        let attString = NSMutableAttributedString()
        
        if let userMessage = message as? UserChatMessage {
            let usernameColor = userMessage.anonymous ? ChatColours.grey : color(name: userMessage.name)
            let username = NSAttributedString(string: "\(userMessage.name): ", attributes: [
                NSForegroundColorAttributeName: usernameColor,
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
        
        if let userMessage = message as? UserChatMessage {
            let rawString = messageLabel.attributedText.string
            let rawNSString = rawString as NSString
            
            let robotRange = rawNSString.range(of: "[\(userMessage.robotName)]")
            if robotRange.location != NSNotFound, let url = URL(string: "letsrobot://robot/\(userMessage.robotName)") {
                messageLabel.addLink(to: url, with: robotRange)
            }
            
            let senderRange = rawNSString.range(of: "\(userMessage.name):")
            if senderRange.location != NSNotFound, let url = URL(string: "letsrobot://user/\(userMessage.name)") {
                let usernameColor = userMessage.anonymous ? ChatColours.grey : color(name: userMessage.name)
                messageLabel.addLink(with: NSTextCheckingResult.linkCheckingResult(range: senderRange, url: url), attributes: [
                    NSForegroundColorAttributeName: usernameColor,
                    NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
                ])
            }
            
            let matches = rawString.rangesMatching(pattern: "\\@(\\w+)")
            for match in matches {
                guard let nameMatch = match.first else { continue }
                let name = rawNSString.substring(with: nameMatch)
                guard Socket.shared.users.first(where: { $0.username == name }) != nil else { continue }
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
    }
    
}
