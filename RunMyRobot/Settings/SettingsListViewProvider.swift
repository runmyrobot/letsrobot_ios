//
//  SettingsListViewProvider.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 06/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation

protocol SettingsListViewProvider {
    var cellCount: Int { get }
    func cellInfo(for index: Int) -> [String: Any]
}

class UserSettingsListProvider: SettingsListViewProvider {
//    USER:
//    - Description (Text)
//    - Phone Number (Text; different keyboard)
//    - Profile Picture (Image)
//    - Moderators? (Rich Editor)
//    - Robits?
    
    var cellCount: Int {
        return 7
    }
    
    func cellInfo(for index: Int) -> [String : Any] {
        return [
            [
                "title": "Profile Settings",
                "type": "title"
            ],
            [
                "title": "UPDATE AVATAR",
                "image": User.current?.avatarUrl as Any,
                "type": "picture"
            ],
            [
                "title": "DESCRIPTION",
                "subtitle": "Update your profile description seen be all users!",
                "type": "textfield",
                "keyboard": "default",
                "placeholder": "On a mission to save Pam"
            ],
            [
                "title": "Notification Settings",
                "type": "title"
            ],
            [
                "title": "GLOBAL NOTIFICATIONS",
                "subtitle": "Manual notifications by site administrators when special events begin!",
                "type": "toggle"
            ],
            [
                "title": "GO LIVE NOTIFICATIONS",
                "subtitle": "You will be notified when a robot you're subscribed to goes live!",
                "type": "toggle"
            ],
            [
                "title": "STUCK NOTIFICATIONS",
                "subtitle": "If one of your robots gets stuck, users can notify you to help it!",
                "type": "toggle"
            ]
        ][index]
    }
}

class SubscriptionsListProvider: SettingsListViewProvider {
    
    var user: CurrentUser? = .current
    
    var cellCount: Int {
        return (user?.subscriptions.count ?? 0) + 1
    }
    
    func cellInfo(for index: Int) -> [String : Any] {
        guard let subs = user?.subscriptions else { return [:] }
        
        var subsMap = subs.flatMap {
            [
                "name": $0.name,
                "type": "subscription"
            ]
        } as [[String: Any]]
        
        subsMap.insert([
            "title": "Your Subscriptions",
            "type": "title"
        ], at: 0)
        
        return subsMap[index]
    }
    
}

class RobotSettingsListProvider: SettingsListViewProvider {

    var robot: Robot
    
    init(_ robot: Robot) {
        self.robot = robot
    }
    
    var cellCount: Int {
        return 9
    }
    
    func cellInfo(for index: Int) -> [String : Any] {
        return [
            [
                "title": "CHANGE AVATAR",
                "image": robot.avatarUrl as Any,
                "type": "picture"
            ],
            [
                "title": "ROBOT NAME",
                "subtitle": "Update your robot's name as shown to users!",
                "type": "textfield",
                "keyboard": "default",
                "value": robot.name,
                "placeholder": "Robotomous Prime"
            ],
            [
                "title": "ROBOT DESCRIPTION",
                "subtitle": "Update your robot's description as seen on the robot's profile!",
                "type": "textfield",
                "keyboard": "default",
                "value": robot.description as Any,
                "placeholder": "01010011 01001111 01010011"
            ],
            [
                "title": "PUBLIC",
                "subtitle": "Allows all users to see the robot",
                "type": "toggle",
                "value": robot.isPublic as Any
            ],
            [
                "title": "ANONYMOUS CONTROL",
                "subtitle": "Allows users who are not logged in to control your robot",
                "type": "toggle",
                "value": robot.isAnonymousControlEnabled as Any
            ],
            [
                "title": "PROFANITY FILTER",
                "subtitle": "I don't actually know what this toggle does",
                "type": "toggle",
                "value": robot.isProfanityFiltered as Any
            ],
            [
                "title": "MUTE TEXT-TO-SPEECH",
                "subtitle": "If supported, prevents your robot from vocalising messages sent in chat",
                "type": "toggle",
                "value": robot.isMuted as Any
            ],
            [
                "title": "DEV MODE",
                "subtitle": "Prevents users from being able to interact with the robot whilst you validate it all works!",
                "type": "toggle",
                "value": robot.isDevMode as Any
            ],
            [
                "title": "CUSTOM PANELS",
                "subtitle": "Allows you to start using custom panels; a way to change the default controls of your robot",
                "type": "toggle",
                "value": false
            ],
            [
                "title": "CHANGE CUSTOM PANELS",
                "type": "segue",
                "segue": "ShowCustomPanelEditor"
            ]
        ][index]
    }
}
