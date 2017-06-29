//
//  Router.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 29/06/2017.
//  Copyright © 2017 Let's Robot. All rights reserved.
//

import Foundation

class Router {
    
    @discardableResult
    func handle(_ url: URL, source: String? = nil) -> Bool {
        print("Handle \(url.absoluteString) from source: \(source)")
        return true
    }
    
}
