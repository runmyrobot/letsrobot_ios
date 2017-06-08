//
//  HEXColor.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 07/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// Creates an instance of UIColor by taking a HEX String value
    ///
    /// Example: #FF0000 is equivelent to UIColor.red
    ///
    /// - Parameter hex: A 6 digit HEX value with/without a hash before it
    convenience init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
}
