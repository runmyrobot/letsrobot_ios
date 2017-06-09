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

class AuthenticatedUser: User {
    
    static var current: AuthenticatedUser?
    static var loggedIn: Bool {
        return current != nil
    }
    
    func logout() {
        Alamofire.request("https://runmyrobot.com/logout").response { _ in
            AuthenticatedUser.current = nil
            NotificationCenter.default.post(name: NSNotification.Name("LoginStatusChanged"), object: nil)
        }
    }
}

extension User {
    
    static func authenticate(userString: String, passString: String, callback: @escaping ((User?, Error?) -> Void)) {
        let loginDetails: Parameters = [
            "username": userString,
            "password": passString
        ]
        
        Alamofire.request("https://runmyrobot.com/api/v1/authenticate", method: .post, parameters: loginDetails).response { response in
            if let error = response.error {
                callback(nil, RobotError.requestFailure(original: error))
                return
            }
            
            if let data = response.data {
                let json = JSON(data)
                guard json.type != .null, let user = AuthenticatedUser(json: json), user.username == userString.lowercased() else {
                    let message = String(data: data, encoding: .utf8)
                    
                    if message == "Unauthorized" {
                        callback(nil, RobotError.invalidLoginDetails)
                    } else {
                        callback(nil, RobotError.parseFailure)
                    }
                    
                    return
                }
                
                AuthenticatedUser.current = user
                callback(user, nil)
            }
        }
    }
    
}
