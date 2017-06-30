//
//  Socket+Moderation.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 30/06/2017.
//  Copyright © 2017 Let's Robot. All rights reserved.
//

import Foundation

extension Socket {
    
//    UserRoles:
//    case staff
//    case globalModerator
//    ^- blockUser, globalBlockUser, timeoutUser (Note: timeoutUser for these roles is global)
//
//    case moderator
//    ^- blockUserForRobocaster, timeoutUser
//
//    case owner
//    ^- blockUser, timeoutUser
    
    func timeout(user: User, robot: Robot) {
        let dict = [
            "username": user.username,
            "robot_id": robot.id,
            "robot_name": robot.name
        ] as [String: Any]
        
        socket?.emit("timeoutUser", dict)
    }
    
    func blockForRobocaster(user: User, robot: Robot) {
        let dict = [
            "username": user.username,
            "robot_id": robot.id,
            "robot_name": robot.name
        ] as [String: Any]
        
        socket?.emit("blockUserForRobocaster", dict)
    }
    
    func block(user: User, global: Bool = false) {
        socket?.emit(global ? "globalBlockUser" : "blockUser", user.username)
    }
    
    // timeoutUser will become global automatically as an admin
    // blockUserForRobocaster is what a robocaster's moderators send in order to block users on behalf of the robocaster
    // blockUser simply blocks users from your current account
    // globalBlockUser is meant for admins only and will block a user site-wide
}
