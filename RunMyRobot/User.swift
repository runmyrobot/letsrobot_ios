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
    var robotName: String?
    
    init(username: String, robotName: String? = nil) {
        self.username = username
        self.robotName = robotName
    }
    
    init?(json: JSON) {
        guard let name = json["user", "username"].string else {
            return nil
        }
        
        self.username = name
    }
}

class CurrentUser: User {
    
    static var loggedIn: Bool {
        // Check that we have a current user
        guard let current = User.current else { return false }
        
        // Validate that the user default matches the current user (minor safety check)
        return UserDefaults.standard.currentUsername == current.username
    }
    
    var description: String?
    var avatarUrl: URL?
    var subscriptions = [RobotSubscription]()
    var robots = [Robot]()
    
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
    
    func isSubscribed(to robotId: String) -> Bool {
        return subscriptions.first(where: { $0.id == robotId }) != nil
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
            
            if subscribe {
                guard let subscription = RobotSubscription(json: json) else {
                    callback(RobotError.parseFailure)
                    return
                }
                
                self.subscriptions.append(subscription)
            } else {
                if let index = self.subscriptions.index(where: { $0.id == robotId }) {
                    self.subscriptions.remove(at: index)
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
            
            // spendable_robits
            
            if let subscriptionsArray = json["subscriptions"].array {
                for sub in subscriptionsArray {
                    guard let subscription = RobotSubscription(json: sub) else { continue }
                    self.subscriptions.append(subscription)
                }
            }
            
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
            callback(self, nil)
        }
    }
}

struct RobotSubscription {
    var id: String
    var name: String
    var owner: String
    
    init?(json: JSON) {
        guard let id = json["robot_id"].string,
              let name = json["robot_name"].string,
              let owner = json["owner"].string else { return nil }
        
        self.id = id
        self.name = name
        self.owner = owner
    }
}
