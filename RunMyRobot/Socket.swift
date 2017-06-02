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
    
    typealias Message = (author: String, message: String, anonymous: Bool)
    var chatMessages = [Message]()
    var socket: SocketIOClient?
    var chatCallback: ((Message) -> Void)?
    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    func start() {
        if let url = URL(string: "https://runmyrobot.com:\(Config.shared?.socketPort ?? 8000)") {
            socket = SocketIOClient(socketURL: url, config: [.log(false)])
            
            socket?.on(clientEvent: .connect) { (data, ack) in
                print("connect")
            }
            
            socket?.on(clientEvent: .disconnect) { (data, ack) in
                print("disconnect", data, ack)
            }
            
            socket?.on(clientEvent: .error) { (data, ack) in
                print("error", data, ack)
            }
            
            socket?.on(clientEvent: .reconnect) { (data, ack) in
                print("reconnect", data, ack)
            }
            
            socket?.on(clientEvent: .reconnectAttempt) { (data, ack) in
                print("reconnectAttempt", data, ack)
            }
            
            socket?.on(clientEvent: .statusChange) { (data, ack) in
                print("statusChange", (data.first as? SocketIOClientStatus)?.rawValue ?? -1)
            }
            
            socket?.onAny { (event) in
                let ignore = [
                    "pip", "robot_command_has_hit_webserver", "aggregate_color_change", "exclusive_control_status", // Incomplete
                    "connect", "disconnect", "error", "reconnect", "reconnectAttempt", "statusChange", // Client Events
                    "news", "num_viewers", "robot_statuses", "chat_message_with_name", // Implemented
                    "users_list", "charge_state" // No Purpose
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
                print("🎲 [VIEWER COUNT] \(data)")
            }
            
            socket?.on("robot_statuses") { (data, ack) in
                guard let data = data.first, let statuses = JSON(data)["robot_statuses"].array else { return }
                
                var changes = false
                for status in statuses {
                    guard let id = status["robot_id"].string else { continue }
                    
                    if var robot = Config.shared?.robots[id] {
                        let before = robot.live
                        robot.live = status["status"].string == "online"
                        let after = robot.live
                        
                        if before != after {
                            Config.shared?.robots[id] = robot
                            changes = true
                        }
                    }
                }
                
                if changes {
                    // Update Listing
                }
            }
            
            socket?.on("chat_message_with_name") { (data, ack) in
                guard let data = data.first else { return }
                let json = JSON(data)
                
                let anonymous = json["anonymous"].boolValue
                let name = json["name"].stringValue
                let text = json["message"].stringValue
                
                let message: Message = (name, text, anonymous)
                self.chatMessages.append(message)
                
                if self.chatMessages.count > 100 {
                    self.chatMessages.removeFirst()
                }
                
                self.chatCallback?(message)
                
                print("💬 [\(name)] \(text) (/\(self.chatMessages.count))")
            }
            
            socket?.connect()
        }
    }
    
    func chat(_ message: String, robot: Robot) {
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
