//
//  UserDefaults.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 10/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    /// Stores the epoch date when the app last went to background
    var lastActive: Double {
        get { return double(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    
    /// Stores the epoch date when the app last went to background
    var sendCrashReports: Bool {
        get { return !bool(forKey: #function) }
        set { set(!newValue, forKey: #function) }
    }
    
    /// Stores whether the current device should receive "Go Live" notifications
    var goLiveNotifications: Bool {
        get { return !bool(forKey: #function) }
        set { set(!newValue, forKey: #function); User.current?.syncNotificationTags() }
    }
    
}
