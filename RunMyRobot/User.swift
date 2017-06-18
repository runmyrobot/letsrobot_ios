//
//  User.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class User {
    /// Current signed in user
    static var current: CurrentUser?
    
    var username: String
    var description: String?
    var downloaded = false
    var avatarUrl: URL?
    var publicRobots: [Robot] {
        return Config.shared?.robots.values.filter({ $0.owner == username }) ?? []
    }
    
    init(username: String) {
        self.username = username
    }
    
    init?(json: JSON) {
        guard let name = json["user", "username"].string else {
            return nil
        }
        
        self.username = name
    }
    
    func loadPublic(callback: @escaping ((Error?) -> Void)) {
        Networking.requestJSON("/api/v1/accounts/\(username)") { response in
            if let error = response.error {
                callback(RobotError.requestFailure(original: error))
                return
            }
            
            guard let data = response.data else {
                callback(RobotError.noData)
                return
            }
            
            self.downloaded = true
            
            let json = JSON(data)
            self.description = json["profile_description"].string
            
            if let avatarUrl = json["avatar", "medium"].string {
                self.avatarUrl = URL(string: avatarUrl)
            }
            
            callback(nil)
        }
    }
    
    class func get(name: String) -> User? {
        if let user = Socket.shared.users.first(where: { $0.username == name }) {
            return user
        }
        
        if let current = User.current, current.username == name {
            return current
        }
        
        return nil
    }
}

class CurrentUser: User {
    
    static var loggedIn: Bool {
        // Check that we have a current user
        guard let current = User.current else { return false }
        
        // Validate that the user default matches the current user (minor safety check)
        return UserDefaults.standard.currentUsername == current.username
    }
    
    var subscriptions: [Robot] {
        return Robot.all().filter({ $0.subscribers.contains(self.username) })
    }
    
    var spendableRobits = 0
    var currentPayment: Payment?
    var robots = [Robot]()
    
    var isStaff = false
    var isGlobalModerator = false
    private var moderatesFor = [String]()
    
    func isModerator(for robot: Robot) -> Bool {
        guard let owner = robot.owner else { return false }
        return moderatesFor.contains(owner)
    }
    
    func isSubscriber(for robot: Robot) -> Bool {
        return robot.subscribers.contains(username)
    }
    
    func isSubscribed(to robotId: String) -> Bool {
        return subscriptions.first(where: { $0.id == robotId }) != nil
    }
    
    func isOwner(of robot: Robot) -> Bool {
        guard let owner = robot.owner else { return false }
        return username == owner
    }
    
    func role(for robot: Robot) -> UserRole {
        if isStaff {
            return .staff
        }
        
        if isGlobalModerator {
            return .globalModerator
        }
        
        if isModerator(for: robot) {
            return .moderator
        }
        
        if isSubscriber(for: robot) {
            return .subscriber
        }
        
        return .user
    }
    
    func logout(callback: (() -> Void)? = nil) {
        // Simple GET request to the web's logout page is enough to clear all authentication/cookies
        Networking.request("/logout") { _ in
            // Cleanup User Defaults
            UserDefaults.standard.currentUsername = nil
            
            // Remove current user instance
            User.current = nil
            
            // Update UI
            NotificationCenter.default.post(name: NSNotification.Name("LoginStatusChanged"), object: nil)
            
            // Callback for additional functionality
            callback?()
        }
    }
    
    func saveProfile() {
        var data: Parameters = [:]
        if let description = description { data["profile_description"] = description }
        
        Networking.request("/api/v1/accounts", method: .post, parameters: data) { response in
            print("\(response)")
        }
    }
    
    func updateRoles(_ json: JSON) {
        isStaff = json["superuser"].bool ?? false
        isGlobalModerator = json["user", "moderator"].bool ?? false
        moderatesFor = json["user", "moderates_for"].arrayObject as? [String] ?? []
    }
    
    func subscribe(_ subscribe: Bool, robotId: String, callback: @escaping ((Error?) -> Void)) {
        // Determine which endpoint to actually hit
        let endpoint = subscribe ? "subscribe" : "unsubscribe"
        
        // POST request to subscribe/unsubscribe endpoint with robot_id parameter
        Networking.request("/api/v1/accounts/\(endpoint)", method: .post, parameters: ["robot_id": robotId]) { response in
            // Check that we don't have an error, if we do return immediately
            if let error = response.error {
                callback(RobotError.requestFailure(original: error))
                return
            }
            
            // Check that the response has data in order to turn into JSON
            guard let data = response.data else {
                callback(RobotError.noData)
                return
            }
            
            let json = JSON(data)
            
            // Check that the robot_id returned is the same that we passed into it to ensure request consistency
            guard json.type != .null, json["robot_id"].string == robotId else {
                callback(RobotError.inconsistencyException)
                return
            }
            
            let robot = Config.shared?.robots[robotId]
            
            if subscribe {
                if robot?.subscribers.contains(self.username) == false {
                    robot?.subscribers.append(self.username)
                }
            } else {
                if let index = robot?.subscribers.index(of: self.username) {
                    robot?.subscribers.remove(at: index)
                }
            }
            
            // Assume it all worked correctly
            callback(nil)
        }
    }
    
    func load(callback: @escaping ((CurrentUser?, Error?) -> Void)) {
        // GET request to accounts endpoint which returns information about authenticated user
        Networking.requestJSON("/api/v1/accounts") { response in
            // Check that we don't have an error, if we do return immediately
            if let error = response.error {
                callback(nil, RobotError.requestFailure(original: error))
                return
            }
            
            guard let data = response.data else {
                callback(nil, RobotError.noData)
                return
            }
            
            let json = JSON(data)
            
            // Check that the web's authenticated user matches the locally known username
            guard json.type != .null, json["username"].string == self.username else {
                callback(nil, RobotError.inconsistencyException)
                return
            }
            
            if let avatarUrl = json["avatar", "medium"].string {
                self.avatarUrl = URL(string: avatarUrl)
            }
            
            self.spendableRobits = json["spendable_robits"].int ?? 0
            self.description = json["profile_description"].string
            
            if let robots = json["robots"].array {
                for robotJSON in robots {
                    if let robot = Robot(json: robotJSON) {
                        self.robots.append(robot)
                    }
                }
            }
            
            // Update the user defaults and singleton reference
            UserDefaults.standard.currentUsername = self.username
            User.current = self
            
            // Intentionally calling this after User.current so that Robot.get can get all robots
            if let subscriptions = json["subscriptions"].array {
                for subscriptionJson in subscriptions {
                    if let robot = Robot.get(name: subscriptionJson["robot_name"].stringValue) {
                        robot.subscribers.append(self.username)
                    }
                }
            }
            
            callback(self, nil)
        }
    }
}

enum UserRole {
    case staff
    case globalModerator
    case moderator
    case subscriber
    case user
}
