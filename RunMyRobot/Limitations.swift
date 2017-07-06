//
//  Limitations.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 06/07/2017.
//  Copyright © 2017 Let's Robot. All rights reserved.
//

import Foundation

class Limitations {
    
    static var loadColours: Bool {
        return Device.Size.current != .iPhone4
    }
    
}
