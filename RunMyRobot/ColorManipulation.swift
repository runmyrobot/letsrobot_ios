//
//  ColorManipulation.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 12/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

extension UIColor {
    
    func lighter(by percentage: CGFloat) -> UIColor {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat) -> UIColor {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    private func adjust(by percentage: CGFloat) -> UIColor {
        var r: CGFloat = 0,
        g: CGFloat = 0,
        b: CGFloat = 0,
        a: CGFloat = 0
        
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }
        
        return self
    }
}
