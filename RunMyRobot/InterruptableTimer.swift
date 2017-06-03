//
//  InterruptableTimer.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 03/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation

class InterruptableTimer: NSObject {
    
    var timer: Foundation.Timer?
    var callback: (() -> Void)?
    
    func schedule(after interval: TimeInterval, action: @escaping (() -> Void)) {
        // Cancel any current timer on the same object
        cancel()
        
        callback = action
        
        timer = Foundation.Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(callAction),
            userInfo: nil,
            repeats: false
        )
    }
    
    func callAction() {
        callback?()
    }
    
    func cancel() {
        timer?.invalidate()
        timer = nil
        callback = nil
    }

    
}
