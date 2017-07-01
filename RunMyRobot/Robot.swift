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
    static var active: Robot?
    
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
    private var panels: [ButtonPanel]?
    
    var subscribers = [String]()
    var updateSubscribers: (() -> Void)?
    var pips = [String: Int]()
    var currentCommand: String?
    var updateControls: (() -> Void)?
    var lastActivity: Date?
    weak var controls: RobotControls?
    var room: String {
        if isGlobalChat == false {
            return owner ?? "global"
        }
        
        return "global"
    }
    
    // Preferences
    var isPublic: Bool?
    var isMuted: Bool?
    var isProfanityFiltered: Bool?
    var isAnonymousControlEnabled: Bool?
    var isDevMode: Bool?
    var isGlobalChat: Bool?
    
    var downloaded = false
    var unsavedChanges: [RobotSettings: Any]?
    var snapshots = [Snapshot]()
    var snapshotsFetched = false
    
    init() {
        name = ""
        id = ""
        live = false
    }
    
    init?(json: JSON) {
        guard let name = json["name"].string ?? json["robot_name"].string,
            let id = json["id"].string ?? json["robot_id"].string else { return nil }
        
        self.name = name
        self.id = id
        self.live = json["status"].string == "online"
        
        if let avatarUrl = json["avatar", "large"].string, let url = URL(string: avatarUrl) {
            self.avatarUrl = url
        } else {
            let thumbnailTemplate = "\(Networking.baseUrl)/images/thumbnails/\(id).jpg"
            self.avatarUrl = URL(string: thumbnailTemplate)
        }
        
        // The following information is only in certain APIs, for example the `/api/v1/accounts` (user robots)
        self.isPublic = json["public"].bool ?? true
        self.isMuted = json["mute"].bool ?? false
        self.isProfanityFiltered = json["strong_filtering"].bool ?? false
        self.isAnonymousControlEnabled = json["allow_anonymous_control"].bool ?? true
        self.isDevMode = json["dev_mode"].bool ?? false
        self.isGlobalChat = !(json["non_global_chat"].bool ?? false)
        self.owner = json["owner"].string
    }
    
    func getControlPanels() -> [ButtonPanel] {
        if let panels = panels {
            return panels
        }
        
        return [ButtonPanel.defaultPanel]
    }
    
    /// Downloads the full feed of information for this robot, some values are only accessible once the download has happened
    func download(callback: @escaping ((Bool) -> Void)) {
        Networking.requestJSON("/internal/robot/\(id)") { [weak self] response in
            guard let rawJSON = response.result.value else {
                print("Something went wrong!", response.error?.localizedDescription ?? "Unknown error")
                callback(false)
                return
            }
            
            let json = JSON(rawJSON)
            User.current?.updateRoles(json) // Always keep user roles up to date
            
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
                self?.subscribers = subscribers
            }
            
            self?.isPublic = json["robot", "public"].bool ?? true
            self?.isMuted = json["robot", "mute"].bool ?? false
            self?.isProfanityFiltered = json["robot", "strong_filtering"].bool ?? false
            self?.isAnonymousControlEnabled = json["robot", "allow_anonymous_control"].bool ?? true
            self?.isDevMode = json["robot", "dev_mode"].bool ?? false
            self?.isGlobalChat = !(json["robot", "non_global_chat"].bool ?? false)
            
            if let lastActiveString = json["robot", "ffmpeg_process_exists_timestamp"].string {
                self?.lastActivity = Socket.shared.formatter.date(from: lastActiveString)
            }
            
            self?.downloaded = true
            callback(true)
        }
    }
    
    func fetchSnapshots(callback: @escaping ((Error?) -> Void)) {
        Networking.requestJSON("/api/v1/snapshots/robot/\(id)") { [weak self] response in
            if let error = response.error {
                callback(RobotError.requestFailure(original: error))
                return
            }
            
            guard let data = response.data else {
                callback(RobotError.noData)
                return
            }
            
            if let json = JSON(data)["snapshots"].array {
                for snapshotJson in json {
                    guard let snapshot = Snapshot(snapshotJson) else { continue }
                    snapshot.robotName = self?.name
                    self?.snapshots.append(snapshot)
                }
            }
            
            self?.snapshotsFetched = true
            callback(nil)
        }
    }
    
    func sendScreenshot(_ image: UIImage, caption: String?, callback: @escaping ((Error?) -> Void)) {
        guard let user = User.current else { return }
        
        var rawCaption: String = caption?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No Caption"
        
        if rawCaption == "" {
            rawCaption = "No Caption"
        }
        
        guard let imageData = UIImageJPEGRepresentation(image, 1) else { return }
        
        let data: Parameters = [
            "image": "data:image/jpeg;base64," + imageData.base64EncodedString(),
            "robot_id": id,
            "robot_name": name,
            "username": user.username,
            "caption": rawCaption
        ]
        
        Networking.request("/api/v1/snapshots", method: .post, parameters: data) { response in
            if let error = response.error {
                callback(RobotError.requestFailure(original: error))
                return
            }
            
            guard let data = response.data else {
                callback(RobotError.noData)
                return
            }
            
            let json = JSON(data)
            
            if json["caption"].string != rawCaption {
                callback(RobotError.inconsistencyException)
                return
            }
            
            callback(nil)
        }
    }
    
    // MARK: - Getters
    
    class func all() -> [Robot] {
        var builder = [Robot]()
        
        if let robots = Config.shared?.robots.values {
            builder.append(contentsOf: robots)
        }
        
        if let robots = User.current?.robots {
            builder.append(contentsOf: robots)
        }
        
        return builder
    }
    
    /// Searches multiple arrays of robots to try and find a robot with the name provided. This will search public and known private robots.
    class func get(name: String, activeOnly: Bool = false) -> Robot? {
        if let active = Robot.active, active.name == name {
            return active
        }
        
        if activeOnly {
            return nil
        }
        
        return all().first(where: {
            $0.name == name
        })
    }
    
    class func get(id: String, activeOnly: Bool = false) -> Robot? {
        if let active = Robot.active, active.id == id {
            return active
        }
        
        if activeOnly {
            return nil
        }
        
        return all().first(where: {
            $0.id == id
        })
    }
    
    /// Fetches the Robot object of the given id if available, callback provides an inout interface for manipulation
    /// Use sparingly!
    class func get(id: String, activeOnly: Bool = false, callback: ((inout Robot, Bool) -> Void)) {
        if var active = Robot.active, active.id == id {
            return callback(&active, true)
        }
        
        if !activeOnly, var robot = all().first(where: { $0.id == id }) {
            return callback(&robot, true)
        }
        
        var robot = Robot()
        callback(&robot, false)
    }
}

struct ButtonPanel {
    struct Button {
        var id: String
        var label: String
        var command: String
        var isPremium = false
        var price = 0
    }
    
    var title: String
    var buttons: [Button]
 
    init?(json: JSON) {
        title = json["button_panel_label"].stringValue
        
        guard let buttonArray = json["buttons"].array, buttonArray.count > 0 else { return nil }
        buttons = [Button]()
        
        for button in buttonArray {
            let id = button["_id"].stringValue
            let label = button["label"].stringValue
            let command = button["command"].stringValue
            let premium = button["premium"].bool ?? false
            let price = button["price"].int ?? 0
            
            buttons.append(Button(id: id, label: label, command: command, isPremium: premium, price: price))
        }
    }
    
    init(title: String, buttons: [Button]) {
        self.title = title
        self.buttons = buttons
    }
    
    static let defaultPanel = ButtonPanel(title: "Default Controls", buttons: [
        // IDs are only used if the command is premium, so setting these to empty strings will not break anything
        Button(id: "", label: "Left", command: "L", isPremium: false, price: 0),
        Button(id: "", label: "Right", command: "R", isPremium: false, price: 0),
        Button(id: "", label: "Forward", command: "F", isPremium: false, price: 0),
        Button(id: "", label: "Backwards", command: "B", isPremium: false, price: 0)
    ])
}

enum RobotSettings: String {
    case isPublic = "public"
    case isMuted = "mute"
    case isProfanityFiltered = "strong_filtering"
    case isAnonymousControlEnabled = "allow_anonymous_control"
    case isDevMode = "dev_mode"
    case isGlobalChat = "non_global_chat"
    case name = "robot_name"
    case description = "robot_description"
}
