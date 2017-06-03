//
//  Threading.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 03/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation

class Threading {
    
    /// Runs callback method on the given thread with (optionally) a delay before execution
    static func run(on thread: Thread, after delay: TimeInterval = 0, execute: @escaping (() -> Void)) {
        var dispatchQueue: DispatchQueue {
            switch thread {
            case .main:
                return .main
            case .background:
                return .global(qos: .background)
            }
        }
        
        dispatchQueue.asyncAfter(
            deadline: DispatchTime.now() + delay,
            execute: execute
        )
    }
    
    enum Thread {
        case main
        case background
    }
    
}
