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
    
    var email: String?
    var avatarUrl: URL?
    
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
            guard json["username"].string == self.username else {
                callback(nil, RobotError.inconsistencyException)
                return
            }
            
            if let avatarUrl = json["avatar", "medium"].string {
                self.avatarUrl = URL(string: avatarUrl)
            }
            
            // subscriptions
            // spendable_robits
            
            // Update the user defaults and singleton reference
            UserDefaults.standard.currentUsername = self.username
            User.current = self
            callback(self, nil)
        }
    }
}

extension User {
    
    static func authenticate(userString: String, passString: String, callback: @escaping ((CurrentUser?, Error?) -> Void)) {
        let loginDetails: Parameters = [
            "username": userString,
            "password": passString
        ]
        
        // POST request to authenticate endpoint using above login details
        Networking.request("/api/v1/authenticate", method: .post, parameters: loginDetails) { response in
            // Check for Alamofire error, and return that immediately
            if let error = response.error {
                callback(nil, RobotError.requestFailure(original: error))
                return
            }
            
            // Ensure the response has some data
            guard let data = response.data else {
                callback(nil, RobotError.noData)
                return
            }
            
            // Create JSON object
            let json = JSON(data)
            
            // Check that we have valid JSON, can create a user from it and the username matches
            // This ensures that it's a user JSON object and is for the same login credentials
            guard json.type != .null, let user = CurrentUser(json: json), user.username == userString else {
                // The alternative expectation is that it will be a string saying "Unauthorized" so check for that
                let message = String(data: data, encoding: .utf8)
                
                if message == "Unauthorized" {
                    callback(nil, RobotError.invalidLoginDetails)
                } else {
                    callback(nil, RobotError.parseFailure)
                }
                
                return
            }
            
//            user.email = json["user", "email"].string
            
            // Load additional information about the user such as profile image and subscriptions
            user.load(callback: callback)
        }
    }
    
}
