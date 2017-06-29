//
//  SettingsListViewProvider.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 06/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

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

    var changeCallback: (() -> Void)
    
    init(changeCallback: @escaping (() -> Void)) {
        self.changeCallback = changeCallback
    }
    
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
                "placeholder": "On a mission to save Pam",
                "value": User.current?.description as Any,
                "callback": { (value: String?) in
                    User.current?.unsavedChanges["profile_description"] = value
                    self.changeCallback()
                }
            ],
            [
                "title": "Notification Settings",
                "type": "title"
            ],
            [
                "title": "GO LIVE NOTIFICATIONS",
                "subtitle": "You will be notified when a robot you're subscribed to goes live!",
                "type": "toggle",
                "value": UserDefaults.standard.goLiveNotifications,
                "callback": { (value: Bool) in
                    UserDefaults.standard.goLiveNotifications = value
                }
            ],
            [
                "title": "Privacy",
                "type": "title"
            ],
            [
                "title": "SEND CRASH REPORTS",
                "subtitle": "We use anonymised crash reports in order to identify and ultimately fix crashes!",
                "type": "toggle",
                "value": UserDefaults.standard.sendCrashReports,
                "callback": { (value: Bool) in
                    UserDefaults.standard.sendCrashReports = value
                }
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
                "robot_id": $0.id,
                "type": "subscription"
            ]
        } as [[String: Any]]
        
        subsMap.insert([
            "title": "You Follow",
            "type": "title"
        ], at: 0)
        
        return subsMap[index]
    }
    
}

class RobotSettingsListProvider: SettingsListViewProvider {

    var robot: Robot
    var segueController: UIViewController
    var changeCallback: (() -> Void)
    
    init(_ robot: Robot, segueController: UIViewController, changeCallback: @escaping (() -> Void)) {
        self.robot = robot
        self.segueController = segueController
        self.changeCallback = changeCallback
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
                "placeholder": "Robotomous Prime",
                "required": true,
                "callback": { (value: String?) in
                    self.robot.unsavedChanges[.name] = value
                    self.changeCallback()
                }
            ],
            [
                "title": "ROBOT DESCRIPTION",
                "subtitle": "Update your robot's description as seen on the robot's profile!",
                "type": "textfield",
                "keyboard": "default",
                "value": robot.description as Any,
                "placeholder": "01010011 01001111 01010011",
                "callback": { (value: String?) in
                    self.robot.unsavedChanges[.description] = value
                    self.changeCallback()
                }
            ],
            [
                "title": "PUBLIC",
                "subtitle": "Allows all users to see the robot",
                "type": "toggle",
                "value": robot.isPublic as Any,
                "callback": { (value: Bool) in
                    self.robot.unsavedChanges[.isPublic] = value
                    self.changeCallback()
                }
            ],
            [
                "title": "ANONYMOUS CONTROL",
                "subtitle": "Allows users who are not logged in to control your robot",
                "type": "toggle",
                "value": robot.isAnonymousControlEnabled as Any,
                "callback": { (value: Bool) in
                    self.robot.unsavedChanges[.isAnonymousControlEnabled] = value
                    self.changeCallback()
                }
            ],
            [
                "title": "PROFANITY FILTER",
                "subtitle": "I don't actually know what this toggle does",
                "type": "toggle",
                "value": robot.isProfanityFiltered as Any,
                "callback": { (value: Bool) in
                    self.robot.unsavedChanges[.isProfanityFiltered] = value
                    self.changeCallback()
                }
            ],
            [
                "title": "GLOBAL CHAT MODE",
                "subtitle": "If enabled, chat messages will be seen by all active users. Otherwise, only people in one of your bots will see it.",
                "type": "toggle",
                "value": robot.isGlobalChat as Any,
                "callback": { (value: Bool) in
                    self.robot.unsavedChanges[.isGlobalChat] = value
                    self.changeCallback()
                }
            ],
            [
                "title": "MUTE TEXT-TO-SPEECH",
                "subtitle": "If supported, prevents your robot from vocalising messages sent in chat",
                "type": "toggle",
                "value": robot.isMuted as Any,
                "callback": { (value: Bool) in
                    self.robot.unsavedChanges[.isMuted] = value
                    self.changeCallback()
                }
            ],
            [
                "title": "DEV MODE",
                "subtitle": "Prevents users from being able to interact with the robot whilst you validate it all works!",
                "type": "toggle",
                "value": robot.isDevMode as Any,
                "callback": { (value: Bool) in
                    self.robot.unsavedChanges[.isDevMode] = value
                    self.changeCallback()
                }
            ],
            [
                "title": "CUSTOM PANELS",
                "subtitle": "Allows you to start using custom panels; a way to change the default controls of your robot",
                "type": "toggle",
                "value": false
            ],
            [
                "title": "CUSTOMISE PANELS",
                "type": "button",
                "callback": {
                    self.segueController.performSegue(withIdentifier: "ShowCustomPanelEditor", sender: nil)
                }
            ]
        ][index]
    }
}
