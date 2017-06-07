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
        return 0
    }
    
    func cellInfo(for index: Int) -> [String : Any] {
        return [
            ["title": "Description", "subtitle": "Two", "type": "toggle"]
        ][index]
    }
}

class NotificationSettingsListProvider: SettingsListViewProvider {
//    NOTIFICATIONS:
//    - Receive "Go Live" (Toggle)
//    - Receive "I'm Stuck" (Toggle)
    
    var cellCount: Int {
        return 2
    }
    
    func cellInfo(for index: Int) -> [String : Any] {
        return [
            [
                "title": "GO LIVE NOTIFICATIONS",
                "subtitle": "You will be notified when a robot you're subscribed to goes live!",
                "type": "toggle"
            ],
            [
                "title": "I'M STUCK NOTIFICATIONS",
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
        return 6//11
    }
    
    func cellInfo(for index: Int) -> [String : Any] {
        return [
            [
                "robots": robots,
                "type": "robotpicker"
            ],
//            [
//                "title": "CHANGE ROBOT NAME",
//                "type": "text"
//            ],
//            [
//                "title": "CHANGE ROBOT DESCRIPTION",
//                "type": "text"
//            ],
//            [
//                "title": "CHANGE ROBOT AVATAR",
//                "subtitle": "This will update the robots avatar used across the site",
//                "type": "image"
//            ],
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
