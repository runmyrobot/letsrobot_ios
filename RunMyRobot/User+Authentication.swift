//
//  User+Authentication.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 12/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Alamofire
import SwiftyJSON
import Crashlytics

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
                Answers.logLogin(withMethod: "App", success: false, customAttributes: [
                    "error": "Alamofire: \(error.localizedDescription)"
                ])
                callback(nil, RobotError.requestFailure(original: error))
                return
            }
            
            // Ensure the response has some data
            guard let data = response.data else {
                Answers.logLogin(withMethod: "App", success: false, customAttributes: [
                    "error": "No Response Data"
                ])
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
                    Answers.logLogin(withMethod: "App", success: false, customAttributes: [
                        "error": "Invalid Details"
                    ])
                    callback(nil, RobotError.invalidLoginDetails)
                } else {
                    Answers.logLogin(withMethod: "App", success: false, customAttributes: [
                        "error": "Parse Failure"
                    ])
                    callback(nil, RobotError.parseFailure)
                }
                
                return
            }
            
            Answers.logLogin(withMethod: "App", success: true, customAttributes: nil)
            
            // Load additional information about the user such as profile image and subscriptions
            user.load(callback: callback)
        }
    }
    
}
