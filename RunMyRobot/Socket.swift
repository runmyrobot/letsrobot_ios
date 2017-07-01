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
    
    var showConnectionMessages = false
    var viewController: UIViewController? {
        guard var top = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        while let presented = top.presentedViewController {
            top = presented
        }
        
        return top
    }
    
    func start(callback: @escaping ((Bool) -> Void)) { // swiftlint:disable:this function_body_length cyclomatic_complexity
        if let url = URL(string: "\(Networking.baseUrl):\(Config.shared?.socketPort ?? 8000)") {
            socket = SocketIOClient(socketURL: url, config: [.log(false)])
            
            socket?.on(clientEvent: .connect) { (_, _) in
                print("✅ [SOCKET] Connected")
                callback(true)
                if self.showConnectionMessages {
                    self.viewController?.showMessage("Connected", type: .success)
                }
            }
            
            socket?.on(clientEvent: .disconnect) { (_, _) in
                print("⛔️ [SOCKET] Disconnected")
                
                if self.showConnectionMessages {
                    self.viewController?.showMessage("Disconnected", type: .error)
                }
            }
            
            socket?.on(clientEvent: .error) { (data, ack) in
                print("‼️ [SOCKET] Error", data, ack)
                
                if self.showConnectionMessages {
                    self.viewController?.showMessage("Socket Error", type: .error)
                }
            }
            
            socket?.on(clientEvent: .reconnect) { (data, ack) in
                print("♻︎ [SOCKET] Reconnect", data, ack)
                
                if self.showConnectionMessages {
                    self.viewController?.showMessage("Socket Reconnecting", type: .info, options: [.autoHide(false)])
                }
            }
            
            socket?.on(clientEvent: .reconnectAttempt) { (data, ack) in
                print("♻︎ [SOCKET] Reconnect Attempt", data, ack)
                
                if self.showConnectionMessages {
                    self.viewController?.showMessage("Socket Reconnecting", type: .info, options: [.autoHide(false)])
                }
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
                        "charge_state", // No Purpose
                        "global_users_list", "channel_users_list", "account_robits" // WIP
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
                    guard let robot = Robot.get(id: robotId, activeOnly: true) else { return }
                    
                    let count = json["users"].dictionaryObject?.count ?? 0
                    guard let command = json["command"].string else { return }
                    // This won't actually work long term as we need to get the colour out as well
                    // Currently unused (v2)
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
                    guard let robot = Robot.get(id: robotId, activeOnly: true) else { return }
                        
                    let command = json["command"].string
                    robot.currentCommand = command == "stop" ? nil : command
                    robot.updateControls?()
                }
            }
            
            socket?.on("account_robits") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first else { return }
                    let json = JSON(data)
                    
                    guard let user = User.current else { return }
                    guard json["username"].string == user.username else { return }
                    guard let robits = json["spendable_robits"].int else { return }
                    
                    let previous = user.spendableRobits
                    user.spendableRobits = robits
                    let diff = robits - previous
                    
                    Threading.run(on: .main) {
                        User.current?.updateRobits?(diff)
                    }
                }
            }
            
            socket?.on("not_enough_robits") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first else { return }
                    let json = JSON(data)
                    
                    guard let user = User.current else { return }
                    guard json["username"].string == user.username else { return }
                    
                    Threading.run(on: .main) {
                        User.current?.updateRobits?(0)
                    }
                }
            }
            
            /// Website flashes the button for 200ms
            socket?.on("robot_command_has_hit_webserver") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first else { return }
                    let json = JSON(data)
                    
                    guard let command = json["command"].string else { return }
                    guard let robotId = json["robot_id"].string else { return }
                    guard let robot = Robot.get(id: robotId, activeOnly: true) else { return }
                    
                    Threading.run(on: .main) {
                        robot.controls?.flashCommand(command)
                    }
                }
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
                Threading.run(on: .background) {
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
                        Threading.run(on: .main) {
                            NotificationCenter.default.post(name: NSNotification.Name("RobotsChanged"), object: nil)
                        }
                    }
                }
            }
            
            socket?.on("chat_message_with_name") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first else { return }
                    self.chat.didReceiveMessage(JSON(data))
                }
            }
            
            socket?.on("channel_users_list") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first, let userJSON = JSON(data).dictionary else { return }
                    
                    var builder = [User]()
                    
                    for (room, value) in userJSON {
                        for singleUser in Array(value.dictionaryValue.values) {
                            let username = singleUser["user", "username"].stringValue
        
                            let user = User(username: username)
                            user.currentRobotId = singleUser["robot_id"].string
                            user.anonymous = singleUser["user", "anonymous"].bool ?? false
                            user.usernameColorRaw = singleUser["user", "username_color"].string
                            user.room = room
        
                            if let avatar = singleUser["user", "avatar", "thumbnail"].string {
                                user.avatarUrl = URL(string: avatar)
                            }
                            
                            builder.append(user)
                        }
                    }
                    
                    self.users = builder
                    
                    Threading.run(on: .main) {
                        NotificationCenter.default.post(name: NSNotification.Name("UpdateActiveUsers"), object: nil)
                    }
                }
            }
            
            socket?.on("subscription_state_change") { (data, _) in
                Threading.run(on: .background) {
                    guard let data = data.first else { return }
                    let json = JSON(data)
                    
                    guard let robot = Robot.get(id: json["robot_id"].stringValue) else { return }
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
                    
                    Threading.run(on: .main) {
                        robot.updateSubscribers?()
                    }
                }
            }
            
            socket?.on("registered_user_active") { (data, _) in
                Threading.run(on: .background) {
                    // We only care about this socket if the user is anonymous
                    guard !CurrentUser.loggedIn else { return }
                    
                    guard let data = data.first else { return }
                    let json = JSON(data)
                    
                    // Don't ask why the JSON name is wrong. Blame Theo!
                    guard let robotId = json["robot_name"].string else { return }
                    guard let robot = Robot.get(id: robotId, activeOnly: true) else { return }
                    
                    Threading.run(on: .main) {
                        robot.controls?.showMessage("A registered user currently has priority! Log in for more control!",
                                                    type: .info, options: [.textNumberOfLines(0), .autoHideDelay(3.0)])
                    }
                }
            }
            
            socket?.connect()
        }
    }
    
    func sendDirection(_ button: ButtonPanel.Button, robot: Robot, keyPosition: String) {
        guard socket?.engine?.connected == true else { return }
        
        if robot.isAnonymousControlEnabled == false && !CurrentUser.loggedIn {
            print("Anonymous user tried to send direction!")
            return
        }
        
        if !robot.live {
            print("Robot is not live! Not going to send the command...")
            return
        }
        
        if button.isPremium && User.current?.canAffordPremiumCommand(button) != true {
            print("User is either anonymous or can't afford premium command!")
            return
        }
        
        if button.isPremium {
            // This will be later enforced by a socket event, but doing it client side ensures if there
            // are any network issues then it's synced ASAP
            User.current?.spendableRobits -= button.price
        }
        
        var dict = [
            "command": button.command,
            "_id": robot.id,
            "key_position": keyPosition,
            "timestamp": formatter.string(from: Date()),
            "robot_id": robot.id,
            "robot_name": robot.name,
            "command_id": button.id,
            "premium": button.isPremium
        ] as [String : Any]
        
        if let user = User.current {
            dict["user"] = user.username
        }
        
        Threading.run(on: .socket) {
            self.socket?.emit("command_to_robot", dict)
        }
    }
    
    func selectRobot(_ robot: Robot) {
        let dict = [
            "robot_id": robot.id
        ] as [String : Any]
        
        Threading.run(on: .socket) {
            self.socket?.emit("select_robot", dict)
        }
    }
    
    func sendRobits(amount: Int, recipient: String) {
        let dict = [
            "amount": amount,
            "recipient": recipient
        ] as [String: Any]
        
        Threading.run(on: .socket) {
            self.socket?.emit("send_robits", dict)
        }
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
