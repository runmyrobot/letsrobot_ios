//
//  Robot.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation
import UIImageColors
import Alamofire
import SwiftyJSON

class Robot {
    var name: String
    var id: String
    var live: Bool
    
    /// URL of the robot's avatar, will use a medium pre-approved avatar, or the thumbnail as backup.
    var avatarUrl: URL?
    
    /// A set of colours which are generated based on the avatar image, only set once image has been downloaded
    var colors: UIImageColors?
    
    /// Username of the robot owner (Requires Download)
    var owner: String?
    
    /// Description of the robot (Requires Download)
    var description: String?
    
    /// Array of custom button panels (Requires download; still may be nil if they use default panels)
    var panels: [ButtonPanel]?
    
    var users: [User] {
        return Socket.shared.users.filter { $0.robotName?.lowercased() == name.lowercased() }
    }
    
    var subscribers: [User]?
    
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
            let thumbnailTemplate = "https://runmyrobot.com/images/thumbnails/\(id).jpg"
            self.avatarUrl = URL(string: thumbnailTemplate)
        }
    }
    
    /// Downloads the full feed of information for this robot, some values are only accessible once the download has happened
    func download(callback: @escaping ((Bool) -> Void)) {
        Alamofire.request("https://runmyrobot.com/internal/robot/\(id)").validate().responseJSON { [weak self] response in
            guard let rawJSON = response.result.value else {
                print("Something went wrong!", response.error?.localizedDescription ?? "Unknown error")
                callback(false)
                return
            }
            
            let json = JSON(rawJSON)
            self?.owner = json["robot", "owner"].string
            self?.description = json["robot", "robot_description"].string?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if json["robot", "custom_panels"].boolValue, let panels = json["robot", "panels"].array?.first?["button_panels"].array, panels.count > 0 {
                self?.panels = [ButtonPanel]()
                
                for panel in panels {
                    guard let buttonPanel = ButtonPanel(json: panel) else { continue }
                    self?.panels?.append(buttonPanel)
                }
            }
            
            if let subscribers = json["robot", "subscribers"].arrayObject as? [String] {
                self?.subscribers = subscribers.map { User(username: $0, robotName: nil) }
            }
            
            callback(true)
        }
    }
}

struct ButtonPanel {
    struct Button {
        var label: String
        var command: String
    }
    
    var title: String
    var buttons: [Button]
    
    init?(json: JSON) {
        title = json["button_panel_label"].stringValue
        
        guard let buttonArray = json["buttons"].array, buttonArray.count > 0 else { return nil }
        buttons = [Button]()
        
        for button in buttonArray {
            let label = button["label"].stringValue
            let command = button["command"].stringValue
            
            buttons.append(Button(label: label, command: command))
        }
    }
}