//
//  Device.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 06/07/2017.
//  Copyright © 2017 Let's Robot. All rights reserved.
//

import UIKit

class Device {
    
    /// Returns true if the current device is an iPhone or iPod Touch
    class var isPhone: Bool {
        if let phone = testUsingPhone {
            return phone
        }
        
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// Returns true if the current device is an iPad
    class var isTablet: Bool {
        if let phone = testUsingPhone {
            return !phone
        }
        
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Returns if the device is currently portrait
    class var isPortrait: Bool {
        if let portrait = testUsingPortrait {
            return portrait
        }
        
        return UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
    }
    
    /// Returns if the device is currently landscape
    class var isLandscape: Bool {
        if let portrait = testUsingPortrait {
            return !portrait
        }
        
        return  UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)
    }
    
    /// Returns if the device is in low power mode (false if unsupported)
    class var lowPowerModeEnabled: Bool {
        if let lowPower = testUsingLowPowerMode {
            return lowPower
        }
        
        return ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    // MARK: - For Testing Purposes
    
    /// Should only be set in unit tests, overrides `isPhone` and `isTablet` functions.
    static var testUsingPhone: Bool?
    
    /// Should only be set in unit tests, overrides `lowPowerModeEnabled` function.
    static var testUsingLowPowerMode: Bool?
    
    /// Should only be set in unit tests, overrides `isPortrait` and `isLandscape` functions.
    static var testUsingPortrait: Bool?
    
    /// Should only be set in unit tests, overrides `Device.Size.current`.
    /// Size should be in portrait orientation
    static var testUsingScreenSize: Size?
    
    // MARK: - Device.Size
    
    class Size {
        
        // MARK: - Device Sizes
        static let iPhone4      = Size(width: 320, height: 480)
        static let iPhone5      = Size(width: 320, height: 568)
        static let iPhone6      = Size(width: 375, height: 667)
        static let iPhone6Plus  = Size(width: 414, height: 736)
        static let iPad         = Size(width: 768, height: 1024)
        static let iPadPro      = Size(width: 1024, height: 1366)
        
        // MARK: - Variables
        var width: CGFloat
        var height: CGFloat
        var portrait: Size {
            return Size(width: width, height: height)
        }
        var landscape: Size {
            return Size(width: height, height: width)
        }
        var size: CGSize {
            return CGSize(width: width, height: height)
        }
        
        // MARK: - Initialiser
        private init(width: CGFloat, height: CGFloat) {
            self.width = width
            self.height = height
        }
        
        // MARK: - Helper Functions
        class var current: Size {
            if let size = Device.testUsingScreenSize {
                return size
            }
            
            return Size(width: CGFloat(width), height: CGFloat(height))
        }
        
        fileprivate class func compare(_ lhs: Size, _ rhs: Size, comparisonMethod: (CGFloat, CGFloat) -> Bool) -> Bool {
            
            // Portrait Check
            let lhsPortrait = lhs.portrait
            let rhsPortrait = rhs.portrait
            guard comparisonMethod(lhsPortrait.width, rhsPortrait.width) else { return false }
            guard comparisonMethod(lhsPortrait.height, rhsPortrait.height) else { return false }
            
            // Landscape Check
            let lhsLandscape = lhs.landscape
            let rhsLandscape = rhs.landscape
            guard comparisonMethod(lhsLandscape.width, rhsLandscape.width) else { return false }
            guard comparisonMethod(lhsLandscape.height, rhsLandscape.height) else { return false }
            
            return true
        }
        
        /// Returns the device width irrespective of orientation
        private class var width: NSInteger {
            return min(Int(UIScreen.main.bounds.width), Int(UIScreen.main.bounds.height))
        }
        
        /// Returns the device height irrespective of orientation
        private class var height: NSInteger {
            return max(Int(UIScreen.main.bounds.width), Int(UIScreen.main.bounds.height))
        }
    }
    
}

// MARK: - Device.Size Comparison and Equatable Protocol Methods

func == (lhs: Device.Size, rhs: Device.Size) -> Bool {
    return Device.Size.compare(lhs, rhs, comparisonMethod: { (left: CGFloat, right: CGFloat) in
        return left == right
    })
}

func != (lhs: Device.Size, rhs: Device.Size) -> Bool {
    return !(lhs == rhs)
}

func <= (lhs: Device.Size, rhs: Device.Size) -> Bool {
    return Device.Size.compare(lhs, rhs, comparisonMethod: { (left: CGFloat, right: CGFloat) in
        return left <= right
    })
}

func >= (lhs: Device.Size, rhs: Device.Size) -> Bool {
    return Device.Size.compare(lhs, rhs, comparisonMethod: { (left: CGFloat, right: CGFloat) in
        return left >= right
    })
}

func < (lhs: Device.Size, rhs: Device.Size) -> Bool {
    return Device.Size.compare(lhs, rhs, comparisonMethod: { (left: CGFloat, right: CGFloat) in
        return left < right
    })
}

func > (lhs: Device.Size, rhs: Device.Size) -> Bool {
    return Device.Size.compare(lhs, rhs, comparisonMethod: { (left: CGFloat, right: CGFloat) in
        return left > right
    })
}
