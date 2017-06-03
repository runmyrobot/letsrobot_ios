//
//  ChatMessageTableViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 02/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

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
    @IBOutlet var messageLabel: UILabel!
    
    func setMessage(_ message: ChatMessage) {
        let fullMessage = "\(message.author): [\(message.robotName)] \(message.message)"
        guard let regex = try? NSRegularExpression(pattern: "(\\w*:) \\[(.*)\\] (.*)", options: .caseInsensitive) else { return }
        let matches = regex.matches(in: fullMessage, options: .anchored, range: NSRange(location: 0, length: fullMessage.characters.count)).first
        
        let attributedString = NSMutableAttributedString(string: fullMessage, attributes: [
            NSForegroundColorAttributeName: UIColor.white
        ])
        
        guard let authorRange = matches?.rangeAt(1) else { return }
        guard let robotRange = matches?.rangeAt(2) else { return }
        // Range 3 is the actual message
        
        // Author (including colon)
        let usernameColor = message.anonymous ? ChatColours.grey : color(name: message.author)
        attributedString.addAttributes([
            NSForegroundColorAttributeName: usernameColor,
            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        ], range: authorRange)
        
        // Robot (not including square brackets)
        let robotName = (fullMessage as NSString).substring(with: robotRange)
        let robot = Config.shared?.robots.first(where: { $0.value.name == robotName })
        let robotColor = robot?.value.colors?.primaryColor
        attributedString.addAttributes([
            // Idea was to use the robotColor here, but this can sometimes conflict with the background color.
            // For now we will keep it white but bold it to stand out from the rest of the text!
            // Plan is to make this tappable to allow the user to switch to the robot
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: robotColor == nil ? UIFontWeightMedium : UIFontWeightSemibold)
        ], range: robotRange)
        
        messageLabel.attributedText = attributedString
    }
    
    func hash(name: NSString) -> Int {
        var hash: Int = 0
        
        for i in 0 ..< name.length {
            let char = Int(name.character(at: i))
            hash = char + ((hash << 5) - hash)
        }
        
        return hash
    }
    
    func color(name: String) -> UIColor {
        let nameHash = hash(name: name as NSString)
        
        switch nameHash % 7 {
        case 0: return ChatColours.blue // 21BCE5
        case 1: return ChatColours.grey // 97E062
        case 2: return ChatColours.yellow // F3EB48
        case 3: return ChatColours.purple // 5F79FF
        case 4: return ChatColours.orange // F9AA67
        case 5: return ChatColours.pink // F16B74
        case 6: return ChatColours.violet // A652Af
        default: return ChatColours.blue // 21BCE5
        }
    }

}
