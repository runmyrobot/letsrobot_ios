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
        guard let current = User.current else { return false }
        return UserDefaults.standard.currentUsername == current.username
    }
    
    func logout() {
        Networking.request("/logout") { _ in
            // Cleanup User Defaults
            UserDefaults.standard.currentUsername = nil
            UserDefaults.standard.currentAvatarUrl = nil
            
            // Remove current user instance
            User.current = nil
            
            // Update UI
            NotificationCenter.default.post(name: NSNotification.Name("LoginStatusChanged"), object: nil)
        }
    }
    
    func load(callback: @escaping ((CurrentUser?, Error?) -> Void)) {
        Networking.requestJSON("/api/v1/accounts") { response in
            print("\(response)")
            // username (validate)
            // subscriptions
            // avatar
            // spendable_robits
            
        }
    }
}

extension User {
    
    static func authenticate(userString: String, passString: String, callback: @escaping ((CurrentUser?, Error?) -> Void)) {
        let loginDetails: Parameters = [
            "username": userString,
            "password": passString
        ]
        
        Networking.request("/api/v1/authenticate", method: .post, parameters: loginDetails) { response in
            if let error = response.error {
                callback(nil, RobotError.requestFailure(original: error))
                return
            }
            
            if let data = response.data {
                let json = JSON(data)
                guard json.type != .null, let user = CurrentUser(json: json), user.username == userString else {
                    let message = String(data: data, encoding: .utf8)
                    
                    if message == "Unauthorized" {
                        callback(nil, RobotError.invalidLoginDetails)
                    } else {
                        callback(nil, RobotError.parseFailure)
                    }
                    
                    return
                }
                
                UserDefaults.standard.currentUsername = user.username
                User.current = user
                callback(user, nil)
            }
        }
    }
    
}
