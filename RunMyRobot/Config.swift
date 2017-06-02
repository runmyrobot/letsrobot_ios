//
//  Config.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 30/05/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIImageColors

extension Config {
    
    static var shared: Config?
    
    static func download(callback: @escaping ((Config) -> Void)) {
        Alamofire.request("https://runmyrobot.com/internal/").validate().responseJSON { response in
            if let rawJSON = response.result.value {
                let config = Config(json: JSON(rawJSON))
                Config.shared = config
                
                // TODO: Should we wait for socket to connect before showing content?
                Socket.shared.start()
                callback(config)
            } else {
                print("Something went wrong!")
            }
        }
    }
    
}

class Config {
    
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
            var builder: [Socket.Message] = []
            
            for chatMessage in chatJSON {
                let author = chatMessage["username"].stringValue
                let text = chatMessage["message"].stringValue
                let anonymous = chatMessage["anonymous"].boolValue
                builder.append((author, text, anonymous))
            }
            
            Socket.shared.chatMessages = builder
        }
        
        socketPort = json["socket_io_messaging_to_web_client_port"].intValue
        chatSecret = json["chat_secret"].stringValue
    }
    
}

struct Robot {
    var name: String
    var id: String
    var live: Bool
    
    /// URL of the robot's avatar, will use a medium pre-approved avatar, or the thumbnail as backup.
    var avatarUrl: URL?
    
    /// A set of colours which are generated based on the avatar image, only set once image has been downloaded
    var colors: UIImageColors?
    
    init?(json: JSON) {
        guard let name = json["name"].string,
            let id = json["id"].string else { return nil }
        
        self.name = name
        self.id = id
        self.live = json["status"].string == "online"
        
        let approvedAvatar = json["avatar_approved"].bool == true
        if approvedAvatar, let avatarUrl = json["avatar", "medium"].string, let url = URL(string: avatarUrl) {
            self.avatarUrl = url
        } else {
            let thumbnailTemplate = "http://runmyrobot.com/images/thumbnails/{id}.jpg"
            self.avatarUrl = URL(string: thumbnailTemplate.replacingOccurrences(of: "{id}", with: id))
        }
    }
}
