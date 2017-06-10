//
//  UserDefaults.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 10/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    /// Returns the current username if they have previously logged in - used to validate same session
    var currentUsername: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    
    /// Returns the current avatar URL, as saved in a previous session
    var currentAvatarUrl: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    
}
