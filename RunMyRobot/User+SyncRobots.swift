//
//  User+SyncRobots.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 12/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension CurrentUser {
    
    func saveRobots(callback: @escaping ((Error?) -> Void)) {
        var payloads = [[String: Any]]()
        
        robots.forEach {
            if let payload = robotSavePayload($0) {
                payloads.append(payload)
            }
        }
        
        guard payloads.count > 0 else { return }
        
        let data: Parameters = [
            "robots": payloads
        ]
        
        Networking.requestJSON("/api/v1/accounts/robots", method: .post, parameters: data) { response in
            guard let data = response.data else {
                callback(RobotError.noData)
                return
            }
            
            let json = JSON(data)
            
            if json["error"].string != nil {
                callback(RobotError.apiFailure)
                return
            }
            
            // Move all the unsaved changes to their corresponding variables
            self.robots.forEach { robot in
                robot.unsavedChanges.forEach {
                    switch $0.key {
                    case .name:
                        if let name = $0.value as? String {
                            robot.name = name
                        }
                    case .description:
                        if let description = $0.value as? String {
                            robot.description = description
                        }
                    case .isPublic:
                        if let value = $0.value as? Bool {
                            robot.isPublic = value
                        }
                    case .isMuted:
                        if let value = $0.value as? Bool {
                            robot.isMuted = value
                        }
                    case .isDevMode:
                        if let value = $0.value as? Bool {
                            robot.isDevMode = value
                        }
                    case .isProfanityFiltered:
                        if let value = $0.value as? Bool {
                            robot.isProfanityFiltered = value
                        }
                    case .isAnonymousControlEnabled:
                        if let value = $0.value as? Bool {
                            robot.isAnonymousControlEnabled = value
                        }
                    case .isGlobalChat:
                        if let value = $0.value as? Bool {
                            robot.isGlobalChat = value
                        }
                    }
                }
                
                robot.unsavedChanges.removeAll()
            }
            
            callback(nil)
        }
    }
    
    private func robotSavePayload(_ robot: Robot) -> [String: Any]? {
        // Check that this robot actually needs saving
        guard robot.unsavedChanges.count > 0 else { return nil }
        
        var payload = [String: Any]()
        
        payload["robot_id"] = robot.id
        payload["updatedAt"] = Socket.shared.formatter.string(from: Date())
        payload["owner"] = robot.owner
        payload["robot_name"] = robot.unsavedChanges[.name] ?? robot.name
        
        if let description = (robot.unsavedChanges[.description] ?? robot.description as Any) as? String {
            payload["robot_description"] = description
        }
    
        if let isPublic = (robot.unsavedChanges[.isPublic] as? Bool) ?? robot.isPublic {
            payload["public"] = isPublic
        }
        
        if let isDevMode = (robot.unsavedChanges[.isDevMode] as? Bool) ?? robot.isDevMode {
            payload["dev_mode"] = isDevMode
        }
        
        if let isAnonymousControlEnabled = (robot.unsavedChanges[.isAnonymousControlEnabled] as? Bool) ?? robot.isAnonymousControlEnabled {
            payload["allow_anonymous_control"] = isAnonymousControlEnabled
            
        }
        
        if let isProfanityFiltered = (robot.unsavedChanges[.isProfanityFiltered] as? Bool) ?? robot.isProfanityFiltered {
            payload["strong_filtering"] = isProfanityFiltered
        }
        
        if let isMuted = (robot.unsavedChanges[.isMuted] as? Bool) ?? robot.isMuted {
            payload["mute"] = isMuted
        }
        
        if let isGlobalChat = (robot.unsavedChanges[.isGlobalChat] as? Bool) ?? robot.isGlobalChat {
            payload["non_global_chat"] = !isGlobalChat
        }
        
//        payload["custom_panels"] = false
//        payload["panels"] = "[]"
        
        return payload
    }
    
}
