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
    }

}
