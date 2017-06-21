//
//  Socket.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 01/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON

class Socket {
    
    static let shared = Socket()
    private init() { }
    
    var users = [User]()
    
    lazy var chat = Chat()
    
    var socket: SocketIOClient?
    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    func start(callback: @escaping ((Bool) -> Void)) { // swiftlint:disable:this function_body_length cyclomatic_complexity
        if let url = URL(string: "\(Networking.baseUrl):\(Config.shared?.socketPort ?? 8000)") {
            socket = SocketIOClient(socketURL: url, config: [.log(false)])
            
            socket?.on(clientEvent: .connect) { (_, _) in
                print("✅ [SOCKET] Connected")
                callback(true)
            }
            
            socket?.on(clientEvent: .disconnect) { (_, _) in
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
            
            socket?.on(clientEvent: .statusChange) { (data, _) in
                guard let status = data.first as? SocketIOClientStatus else { return }
                
                var message = "Unknown"
                
                switch status {
                case .connected:
                    message = "Connected"
                case .connecting:
                    message = "Connecting"
                case .disconnected:
                    message = "Disconnected"
                case .notConnected:
                    message = "Not Connected"
                }
                
                print("⚠️ [SOCKET] Status Changed: \(message)")
            }
            
            socket?.onAny { (event) in
                Threading.run(on: .background) {
                    let ignore = [
                        "robot_command_has_hit_webserver", "exclusive_control_status", // Incomplete
                        "connect", "disconnect", "error", "reconnect", "reconnectAttempt", "statusChange", // Client Events
                        "news", "num_viewers", "robot_statuses", "chat_message_with_name", "users_list", "subscription_state_change", // Implemented
                        "pip", "aggregate_color_change", "robot_command_has_hit_webserver", "new_snapshot", // Implemented
                        "charge_state" // No Purpose
                    ]
                    
                    if ignore.contains(event.event) {
                        return
                    }
                    
                    print("❓ UNHANDLED EVENT: \(event.event)")
                }
            }
            
            /// Website adds a little dot with the provided colour to the given command button
            socket?.on("pip") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first else { return }
                    let json = JSON(data)
                    
                    guard let robotId = json["robot_id"].string else { return }
                    guard let robot = Robot.get(id: robotId) else { return }
                    
                    let count = json["users"].dictionaryObject?.count ?? 0
                    guard let command = json["command"].string else { return }
                    robot.pips[command] = count
                    robot.updateControls?()
                }
            }
            
            /// Website adds a 5px white border to the given command button
            socket?.on("aggregate_color_change") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first else { return }
                    let json = JSON(data)
                    
                    guard let robotId = json["robot_id"].string else { return }
                    guard let robot = Robot.get(id: robotId) else { return }
                        
                    let command = json["command"].string
                    robot.currentCommand = command == "stop" ? nil : command
                    robot.updateControls?()
                }
                
                /*
                 On the provided robot, only the given command should be highlighted. All others should not be highlighted.
                 
                 {
                    "command" : "R", - Can also be "stop"
                    "robot_id" : "11467183"
                 }
                */
            }
            
            /// Website flashes the button for 200ms
            socket?.on("robot_command_has_hit_webserver") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first else { return }
                    let json = JSON(data)
                    
                    guard let command = json["command"].string else { return }
                    guard let robotId = json["robot_id"].string else { return }
                    guard let robot = Robot.get(id: robotId) else { return }
                    
                    Threading.run(on: .main) {
                        robot.controls?.flashCommand(command)
                    }
                }
                
                /*
                 Probably only want to flash the button if the user is me?
                 
                 {
                     "key_position" : "down",
                     "robot_id" : "11467183",
                     "_id" : "11467183",
                     "user" : "Sherlouk",
                     "robot_name" : "PonyBot",
                     "command" : "R",
                     "timestamp" : "2017-06-14T14:15:24.873Z"
                 }
                 */
            }
            
            socket?.on("news") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first as? [String: String] else { return }
                    
                    for item in data {
                        print("📰 [NEWS]", item.key, item.value)
                    }
                }
            }
            
            socket?.on("num_viewers") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first as? Int else { return }
                    print("🎲 [VIEWER COUNT] \(data) (User Count: \(self.users.count))")
                }
            }
            
            socket?.on("new_snapshot") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first else { return }
                    self.chat.didReceiveMessage(JSON(data))
                }
            }
            
            socket?.on("robot_statuses") { (data, _) in
                guard let data = data.first, let statuses = JSON(data)["robot_statuses"].array else { return }
                
                var changes = false
                for status in statuses {
                    guard let id = status["robot_id"].string else { continue }
                    
                    Robot.get(id: id) { (robot: inout Robot, success) in
                        guard success else { return }
                        
                        let before = robot.live
                        robot.live = status["status"].string == "online"
                        let after = robot.live
                        
                        if before != after {
                            changes = true
                            print("🔄 \(robot.name) is now \(after ? "online" : "offline"). Previously: \(before ? "online" : "offline")")
                            
                            NotificationCenter.default.post(name: NSNotification.Name("RobotStateChanged"), object: nil, userInfo: [
                                "robot_id": robot.id,
                                "online": after
                            ])
                        }
                    }
                }
                
                if changes {
                    NotificationCenter.default.post(name: NSNotification.Name("RobotsChanged"), object: nil)
                }
            }
            
            socket?.on("chat_message_with_name") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first else { return }
                    self.chat.didReceiveMessage(JSON(data))
                }
            }
            
            socket?.on("users_list") { (data, _) in
                guard let data = data.first, let userJSON = JSON(data).dictionary else { return }
                
                var builder = [User]()
                for userJSON in Array(userJSON.values) {
                    let username = userJSON["user", "username"].stringValue
                    
                    let user = User(username: username)
                    user.currentRobotId = userJSON["robot_id"].string
                    
                    builder.append(user)
                }
                
                self.users = builder
                NotificationCenter.default.post(name: NSNotification.Name("UpdateActiveUsers"), object: nil)
            }
            
            socket?.on("subscription_state_change") { (data, _) in
                guard let data = data.first else { return }
                let json = JSON(data)
                guard let robot = Config.shared?.robots[json["robot_id"].stringValue] else { return }
                guard let username = json["username"].string else { return }
                
                if json["subscribed"].boolValue {
                    if robot.subscribers.contains(username) == false {
                        robot.subscribers.append(username)
                    }
                } else {
                    if let index = robot.subscribers.index(of: username ) {
                        robot.subscribers.remove(at: index)
                    }
                }
                
                robot.updateSubscribers?()
            }
            
            socket?.connect()
        }
    }
    
    func sendDirection(_ command: RobotCommand, robot: Robot, keyPosition: String) {
        guard socket?.engine?.connected == true else { return }
        
        var dict = [
            "command": command.rawValue,
            "_id": robot.id,
            "key_position": keyPosition,
            "timestamp": formatter.string(from: Date()),
            "robot_id": robot.id,
            "robot_name": robot.name
        ] as [String : Any]
        
        if let user = User.current {
            dict["user"] = user.username
        }
        
        socket?.emit("command_to_robot", dict)
    }
    
    func selectRobot(_ robot: Robot) {
        let dict = [
            "robot_id": robot.id
        ] as [String : Any]
        
        socket?.emit("select_robot", dict)
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
