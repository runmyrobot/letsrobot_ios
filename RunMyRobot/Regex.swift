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
        let nsString = self as NSString
        
        return rangesMatching(pattern: pattern).map {
            var builder = [String]()
            
            for range in $0 {
                builder.append(nsString.substring(with: range))
            }
            
            return builder
        }
    }
    
    func rangesMatching(pattern: String) -> [[NSRange]] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsString = self as NSString
        
        let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
        return results.map {
            var builder = [NSRange]()
            for i in 1 ..< $0.numberOfRanges {
                builder.append($0.rangeAt(i))
            }
            return builder
        }
    }
    
}
