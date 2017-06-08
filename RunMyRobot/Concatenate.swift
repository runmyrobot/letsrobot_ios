//
//  Concatenate.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 07/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation

/// Allows you to add two dictionaries values together
/// Any duplicated keys will use the value from the right side of the equation
func + <K, V> (left: [K: V], right: [K: V]) -> [K: V] {
    var map = [K: V]()
    
    for (k, v) in left {
        map[k] = v
    }
    
    for (k, v) in right {
        map[k] = v
    }
    
    return map
}
