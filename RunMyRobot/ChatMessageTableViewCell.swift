//
//  ChatMessageTableViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 02/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    
    func setMessage(_ message: Socket.Message) {
        nameLabel.text = message.author + ":"
        messageLabel.text = message.message
        
        nameLabel.textColor = color(name: message.author)
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
        case 0: return UIColor(red: 33/255, green: 188/255, blue: 229/255, alpha: 1)
        case 1: return UIColor(red: 151/255, green: 224/255, blue: 98/255, alpha: 1)
        case 2: return UIColor(red: 243/255, green: 235/255, blue: 72/255, alpha: 1)
        case 3: return UIColor(red: 95/255, green: 121/255, blue: 255/255, alpha: 1)
        case 4: return UIColor(red: 249/255, green: 170/255, blue: 103/255, alpha: 1)
        case 5: return UIColor(red: 241/255, green: 107/255, blue: 116/255, alpha: 1)
        case 6: return UIColor(red: 166/255, green: 82/255, blue: 175/255, alpha: 1)
        default: return UIColor(red: 33/255, green: 188/255, blue: 229/255, alpha: 1)
        }
    }

}
