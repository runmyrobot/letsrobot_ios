//
//  RobotViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 29/05/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import SocketIO
import SwiftyJSON

class RobotViewController: UIViewController {
    
    static let currentRobot = "11467183"
    var socket: SocketIOClient?
    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    @IBOutlet var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.loadRequest(URLRequest(url: URL(string: "https://runmyrobot.com/fullview/\(RobotViewController.currentRobot)")!))
        
        if let url = URL(string: "https://runmyrobot.com:8000") {
            socket = SocketIOClient(socketURL: url, config: [.log(true)])
            
            socket?.on(clientEvent: .connect) { (data, ack) in
                print("connect", data, ack)
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
                print("statusChange", (data.first as? SocketIOClientStatus)?.rawValue)
            }
            
            socket?.onAny { (event) in
                switch event.event {
                case "pip":
                    self.socket(pip: event.items?.first as? [String: Any])
                    break
                case "exclusive_control_status": break
                case "aggregate_color_change": break
                case "news": break
                case "num_viewers": break
                case "charge_state": break
                case "robot_statuses": break
                case "robot_command_has_hit_webserver": break
                case "chat_message_with_name": break
                case "statusChange": break
                case "connect": break
                default:
                    print("🚨 Unhandled Event Name: \(event.event)")
                    
                    if let dict = event.items?.first as? [String: Any] {
                        if let robot_id = dict["robot_id"] {
                            guard String(describing: robot_id) == RobotViewController.currentRobot else { break }
                        }
                    }
                    print(event.items)
                    break
                }
            }
            
            socket?.connect()
            
            // Command List:
            // "L" = Left, "R" = Right, "F" = Forward, "B" = Back
            // "U" = Up, "D" = Down, "O" = Open, "C" = Close
            // "LED_OFF", "LED_FULL", "LED_MED", "LED_LOW"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - SocketIO Methods
    
    func socket(pip data: [String: Any]?) {
        guard let data = data else { return }
        
//        if let command = data["command"] as? String {
//            print(RobotCommand(rawValue: command))
//        }
        
        let id = String(describing: data["robot_id"] ?? "")
        guard id == RobotViewController.currentRobot else { return }
        
        print(data)
    }
    
    @IBAction func didPressButton(_ sender: UIButton) {
        switch sender.tag {
        case 1: // Left
            
            
            let dict = [
                "command": "L",
                "_id": RobotViewController.currentRobot,
                "key_position": "up",
                "timestamp": formatter.string(from: Date()),
                "robot_id": RobotViewController.currentRobot,
                "robot_name": "PonyBot",
                "user": "wipApp"
            ] as [String : Any]
            
//            let json = JSON.parse("{\"command\": \"L\"," +
//                "\"key_position\": \"up\"," +
//                "\"timestamp\": \(formatter.string(from: Date()))," +
//                "\"robot_id\": \(Int(RobotViewController.currentRobot) ?? 0)," +
//                "\"robot_name\": \"PonyBot\"}")
//            print(dict)
            
//            socket?.emitWithAck("command_to_robot", with: [0]).timingOut(after: 15) { data in
//                print("🍏", data)
//            }
//            
//            let json = JSON(dict).rawString() ?? ""
//            print(json)
//            socket?.emit("command_to_robot", with: JSON(dict))
            socket?.emit("command_to_robot", dict)
            
//            socket?.emitWithAck(event: String, with: [Any])
            break
        case 2: // Forward
            break
        case 3: // Backwards
            break
        case 4: // Right
            break
        default:
            print("Unknown Button")
            break
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
