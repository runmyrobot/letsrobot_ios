//
//  DictionarySubscript.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 07/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation

extension Dictionary {
    
    subscript(index: Int) -> (key: Key, value: Value) {
        get {
            return self[self.index(startIndex, offsetBy: index)]
        }
    }
    
}
