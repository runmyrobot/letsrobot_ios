//
//  Config.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 30/05/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation
import SwiftyJSON

class Config {
    
    static var shared: Config?
    
    var chatSecret: String
    var socketPort: Int
    var robots = [String: Robot]()
    
    init(json: JSON) {
        if let robotsJSON = json["robots"].array {
            for robotJSON in robotsJSON {
                if let robot = Robot(json: robotJSON) {
                    self.robots[robot.id] = robot
                }
            }
        }
        
        if let chatJSON = json["chat_messages"].array {
            var builder: [ChatMessage] = []
            
            for chatMessage in chatJSON {
                guard let message = Socket.shared.chat.parseMessage(chatMessage) else { continue }
                builder.append(message)
            }
            
            Socket.shared.chat.messages = Array(builder.suffix(Chat.messageCountCap))
        }
        
        socketPort = json["socket_io_messaging_to_web_client_port"].intValue
        chatSecret = json["chat_secret"].stringValue
    }
    
}
