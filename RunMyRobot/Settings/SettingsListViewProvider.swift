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
        return 5
    }
    
    func cellInfo(for index: Int) -> [String : Any] {
        return [
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
//            [
//                "title": "PHONE NUMBER",
//                "subtitle": "An alternative to push notifications to notify you when one of your favourite robots comes online!",
//                "type": "textfield",
//                "keyboard": "phone",
//                "placeholder": "+1 (555) 555-5555"
//            ]
        ][index]
    }
}

class NotificationSettingsListProvider: SettingsListViewProvider {
    
    var cellCount: Int {
        return 3
    }
    
    func cellInfo(for index: Int) -> [String : Any] {
        return [
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

class RobotSettingsListProvider: SettingsListViewProvider {

    var robots: [String]
    
    init(robots: [String]) {
        self.robots = robots
    }
    
    var cellCount: Int {
        return 7
    }
    
    func cellInfo(for index: Int) -> [String : Any] {
        return [
            [
                "title": "ROBOT NAME",
                "subtitle": "Update your robot's name as shown to users!",
                "type": "textfield",
                "keyboard": "default",
                "placeholder": "On a mission to save Pam"
            ],
            [
                "title": "ROBOT DESCRIPTION",
                "subtitle": "Update your robot's description as seen on the robot's profile!",
                "type": "textfield",
                "keyboard": "default",
                "placeholder": "On a mission to save Pam"
            ],
            [
                "title": "CHANGE ROBOT AVATAR",
                "type": "picture"
            ],
            [
                "title": "PUBLIC",
                "subtitle": "Allows all users to see the robot",
                "type": "toggle"
            ],
            [
                "title": "ANONYMOUS CONTROL",
                "subtitle": "Allows users who are not logged in to control your robot",
                "type": "toggle"
            ],
            [
                "title": "PROFANITY FILTER",
                "subtitle": "I don't actually know what this toggle does",
                "type": "toggle"
            ],
            [
                "title": "MUTE TEXT-TO-SPEECH",
                "subtitle": "If supported, prevents your robot from vocalising messages sent in chat",
                "type": "toggle"
            ],
            [
                "title": "DEV MODE",
                "subtitle": "Prevents users from being able to interact with the robot whilst you validate it all works!",
                "type": "toggle"
            ]
//            [
//                "title": "CUSTOM PANELS",
//                "subtitle": "Allows you to start using custom panels; a way to change the default controls of your robot",
//                "type": "toggle"
//            ],
//            [
//                "title": "CHANGE CUSTOM PANELS",
//                "type": "button" // Will segue to another screen to actually do the customising
//            ]
        ][index]
    }
}
