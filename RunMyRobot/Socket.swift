//
//  Socket.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 01/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON

class Socket {
    
    static let shared = Socket()
    private init() { }
    
    var users = [User]()
    
    var chatMessages = [ChatMessage]()
    var chatCallback: ((ChatMessage) -> Void)?
    
    var socket: SocketIOClient?
    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    func start(callback: @escaping ((Bool) -> Void)) {
        if let url = URL(string: "https://runmyrobot.com:\(Config.shared?.socketPort ?? 8000)") {
            socket = SocketIOClient(socketURL: url, config: [.log(false)])
            
            socket?.on(clientEvent: .connect) { (data, ack) in
                print("✅ [SOCKET] Connected")
                callback(true)
            }
            
            socket?.on(clientEvent: .disconnect) { (data, ack) in
                print("⛔️ [SOCKET] Disconnected")
            }
            
            socket?.on(clientEvent: .error) { (data, ack) in
                print("‼️ [SOCKET] Error", data, ack)
            }
            
            socket?.on(clientEvent: .reconnect) { (data, ack) in
                print("♻︎ [SOCKET] Reconnect", data, ack)
            }
            
            socket?.on(clientEvent: .reconnectAttempt) { (data, ack) in
                print("♻︎ [SOCKET] Reconnect Attempt", data, ack)
            }
            
            socket?.on(clientEvent: .statusChange) { (data, ack) in
                guard let status = data.first as? SocketIOClientStatus else { return }
                
                var message = "Unknown"
                
                switch status {
                case .connected: message = "Connected"
                case .connecting: message = "Connecting"
                case .disconnected: message = "Disconnected"
                case .notConnected: message = "Not Connected"
                }
                
                print("⚠️ [SOCKET] Status Changed: \(message)")
            }
            
            socket?.onAny { (event) in
                let ignore = [
                    "pip", "robot_command_has_hit_webserver", "aggregate_color_change", "exclusive_control_status", // Incomplete
                    "connect", "disconnect", "error", "reconnect", "reconnectAttempt", "statusChange", // Client Events
                    "news", "num_viewers", "robot_statuses", "chat_message_with_name", "users_list", // Implemented
                    "charge_state" // No Purpose
                ]
                
                if ignore.contains(event.event) {
                    return
                }
                
                print(event.event)
            }
            
            socket?.on("news") { (data, ack) in
                guard let data = data.first as? [String: String] else { return }
                
                for item in data {
                    print("📰 [NEWS]", item.key, item.value)
                }
            }
            
            socket?.on("num_viewers") { (data, ack) in
                guard let data = data.first as? Int else { return }
                print("🎲 [VIEWER COUNT] \(data) (User Count: \(self.users.count))")
            }
            
            socket?.on("robot_statuses") { (data, ack) in
                guard let data = data.first, let statuses = JSON(data)["robot_statuses"].array else { return }
                
                var changes = false
                for status in statuses {
                    guard let id = status["robot_id"].string else { continue }
                    
                    if let robot = Config.shared?.robots[id] {
                        let before = robot.live
                        robot.live = status["status"].string == "online"
                        let after = robot.live
                        
                        if before != after {
                            Config.shared?.robots[id] = robot
                            changes = true
                        }
                    } else {
                        // Likely caused by private robots
//                        print("Unknown robot!", status)
                    }
                }
                
                if changes {
                    // Update Listing
                }
            }
            
            socket?.on("chat_message_with_name") { (data, ack) in
                guard let data = data.first else { return }
                guard let message = ChatMessage(json: JSON(data)) else { return }
                
                self.chatMessages.append(message)
                
                if self.chatMessages.count > 100 {
                    self.chatMessages.removeFirst()
                }
                
                self.chatCallback?(message)
                
                print("💬 [\(message.author) @ \(message.robotName)]: \(message.message) (/\(self.chatMessages.count))")
            }
            
            socket?.on("users_list") { (data, ack) in
                guard let data = data.first, let userJSON = JSON(data).dictionary else { return }
                
                var builder = [User]()
                for userJSON in Array(userJSON.values) {
                    let user = User(username: userJSON["user", "username"].stringValue)
                    builder.append(user)
                }
                
                self.users = builder
            }
            
            socket?.connect()
        }
    }
    
    func chat(_ message: String, robot: Robot) {
        guard socket?.engine?.connected == true else { return }
        
        let payload = [
            "message": "[\(robot.name)] " + message,
            "robot_name": robot.name,
            "robot_id": robot.id,
            "secret": Config.shared?.chatSecret ?? "",
            "username": "Sherlouk"
        ] as [String: Any]
        
        socket?.emit("chat_message", payload)
    }
    
    func sendDirection(_ command: RobotCommand, robot: Robot, keyPosition: String) {
        guard socket?.engine?.connected == true else { return }
        
        let dict = [
            "command": command.rawValue,
            "_id": robot.id,
            "key_position": keyPosition,
            "timestamp": formatter.string(from: Date()),
            "robot_id": robot.id,
            "robot_name": robot.name,
            "user": "wipApp"
        ] as [String : Any]
        
        socket?.emit("command_to_robot", dict)
    }
    
}

enum RobotCommand: String {
    case forward = "F"
    case backward = "B"
    case left = "L"
    case right = "R"
    case up = "U"
    case down = "D"
    case open = "O"
    case close = "C"
    case ledOff = "LED_OFF"
    case ledFull = "LED_FULL"
    case ledMed = "LED_MED"
    case ledLow = "LED_LOW"
}

struct User {
    var username: String
}

struct ChatMessage {
    var author: String
    var message: String
    var anonymous: Bool
    var robotName: String
    
    init?(json: JSON) {
        author = json["name"].string ?? json["username"].string ?? "Unknown"
        anonymous = json["anonymous"].boolValue
        
        // Message can come out as an empty string (due to profanity filter)
        // Currently we just don't render this, which is good, but we should maybe change that.
        guard let matches = json["message"].stringValue.matches(pattern: "\\[(.*)\\](.*)").first, matches.count == 2 else { return nil }
        robotName = matches[0].trimmingCharacters(in: .whitespacesAndNewlines)
        message = matches[1].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var robot: Robot? {
        return Config.shared?.robots.first(where: { $0.value.name == robotName })?.value
    }
    
    var user: User? {
        return Socket.shared.users.first(where: { $0.username == author })
    }
}
