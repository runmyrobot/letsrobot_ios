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

extension Config {
    
    static func download(callback: @escaping ((Config) -> Void)) {
        Alamofire.request("https://runmyrobot.com/internal/").validate().responseJSON { response in
            if let rawJSON = response.result.value {
                callback(Config(json: JSON(rawJSON)))
            }
        }
    }
    
}

struct Config {
    
    var robots = [Robot]()
    
    init(json: JSON) {
        if let robotsJSON = json["robots"].array {
            for robotJSON in robotsJSON {
                if let robot = Robot(json: robotJSON) {
                    self.robots.append(robot)
                }
            }
        }
    }
    
}

struct Robot {
    var name: String
    var id: String
    var live: Bool
    var avatarUrl: String
    
    init?(json: JSON) {
        guard let name = json["name"].string,
            let id = json["id"].string else { return nil }
        
        self.name = name
        self.id = id
        self.live = json["status"].string == "online"
        
        let approvedAvatar = json["avatar_approved"].bool == true
        if approvedAvatar, let avatarUrl = json["avatar", "medium"].string {
            self.avatarUrl = avatarUrl
        } else {
            let thumbnailTemplate = "http://runmyrobot.com/images/thumbnails/{id}.jpg"
            self.avatarUrl = thumbnailTemplate.replacingOccurrences(of: "{id}", with: id)
        }
    }
}
