//
//  Regex.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 03/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation

extension String {
    
    func matches(pattern: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsString = self as NSString
        
        let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
        return results.map {
            var builder = [String]()
            for i in 1 ..< $0.numberOfRanges {
                let range = $0.rangeAt(i)
                builder.append(nsString.substring(with: range))
            }
            return builder
        }
    }
    
}
