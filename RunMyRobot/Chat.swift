//
//  Chat.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 11/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ChatMessage: CustomStringConvertible {}

class UserChatMessage: ChatMessage {
    var anonymous: Bool
    var name: String
    var message: String
    var robotName: String
    var room: String?
    var date: Date
    var color: UIColor
    
    init?(_ json: JSON) {
        guard let anonymous = json["anonymous"].bool,
              let name = json["name"].string ?? json["username"].string,
              let fullMessage = json["message"].string else { return nil }
        self.anonymous = anonymous
        self.name = name
        
        let matches = fullMessage.matches(pattern: "\\[(.*)\\] ?(.*)")
        guard let match = matches.first, match.count == 2 else { return nil }
        
        self.robotName = match[0].trimmingCharacters(in: .whitespacesAndNewlines)
        self.message = match[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !anonymous, let colorString = json["username_color"].string {
            self.color = UIColor(hex: colorString)
        } else {
            self.color = UIColor(hex: "#636363")
        }
        
        if let _ = json["time_string"].string {
            // This one will need to convert the /internal timestamp into an actual date
            // Seems to use relative time of "x [minutes/seconds] ago"
            self.date = Date()
        } else {
            self.date = Date()
        }
        
        if let room = json["room"].string {
            self.room = room
        } else {
            self.room = robot?.owner
        }
    }
    
    var description: String {
        return "\(name): [\(robotName)] \(message)"
    }
    
    var robot: Robot? {
        return Config.shared?.robots.values.first(where: {
            $0.name.lowercased() == robotName.lowercased()
        })
    }
    
    var user: User? {
        return Socket.shared.users.first(where: {
            $0.username == name
        })
    }
}

class WootChatMessage: ChatMessage {
    var sender: String
    var robotOwner: String
    var wootValue: Int
    
    init?(_ json: JSON) {
        guard json["name"].string == "LetsBot",
              let message = json["message"].string else { return nil }
        
        let matches = message.matches(pattern: "(.*) sent woot([0-9]+) to (.*) !!")
        guard let match = matches.first, match.count == 3 else { return nil }
        guard let value = Int(match[1]) else { return nil }
        
        self.sender = match[0].trimmingCharacters(in: .whitespacesAndNewlines)
        self.wootValue = value
        self.robotOwner = match[2].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var description: String {
        return "WOOT: \(sender) sent \(wootValue) to \(robotOwner)'s device"
    }
}

class SnapshotMessage: ChatMessage {
    var snapshot: Snapshot
    
    init?(_ json: JSON) {
        guard let snapshot = Snapshot(json["snapshot"]) else { return nil }
        self.snapshot = snapshot
    }
    
    var description: String {
        return "\(snapshot.sender) submitted a new screenshot of \(snapshot.robotName)!"
    }
}

class DefaultChatMessage: ChatMessage {
    var name: String
    var message: String
    
    /*
     {
        "name" : "AdminBot",
        "message" : "shedderrich [TheoBlaster] has been timed out for 5 minute"
     }
     */
    
    init?(_ json: JSON) {
        guard let name = json["name"].string,
              let message = json["message"].string else { return nil }
        
        self.name = name
        self.message = message
    }
    
    var description: String {
        return "\(name): \(message)"
    }
}

class Chat {
    
    static let messageCountCap = 100
    
    var messages = [ChatMessage]()
    var chatCallback: ((ChatMessage) -> Void)?
    
    func didReceiveMessage(_ json: JSON) {
        guard let message = parseMessage(json) else {
            print("Failed to parse: \(json)")
            return
        }
        
        messages.append(message)
        messages = Array(messages.suffix(Chat.messageCountCap))
        print("💬 \(message) (\(messages.count)/\(Chat.messageCountCap))")
        
        chatCallback?(message)
    }
    
    func parseMessage(_ json: JSON) -> ChatMessage? {
        // Attempt to convert the JSON into known objects and extract more information from it
        if let message = UserChatMessage(json) { return message }
        if let message = WootChatMessage(json) { return message }
        if let message = SnapshotMessage(json) { return message }
        
        // Message hasn't matched any known objects, so try and at least get the basic message
        if let message = DefaultChatMessage(json) { return message }
        return nil
    }
    
    func sendMessage(_ message: String, robot: Robot) {
        guard let socket = Socket.shared.socket, socket.engine?.connected == true else { return }
        
        let payload = [
            "message": "[\(robot.name)] " + message,
            "robot_name": robot.name,
            "robot_id": robot.id,
            "secret": Config.shared?.chatSecret ?? ""
        ]
        
        socket.emit("chat_message", payload)
    }
}
