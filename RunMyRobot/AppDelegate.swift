//
//  AppDelegate.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 29/05/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import PopupDialog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics.self])
        
        // Some things can be done on background thread as to not lock up the launching
        Threading.run(on: .background, after: 0) {
            self.setupDefaultAlert()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setupDefaultAlert() {
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled = false
        
        let pcv = PopupDialogContainerView.appearance()
        pcv.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        pcv.cornerRadius    = 2
        pcv.shadowEnabled   = true
        pcv.shadowColor     = UIColor.black
        
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont    = pv.titleFont.withSize(18)
        pv.titleColor   = UIColor.white
        pv.messageFont  = pv.messageFont.withSize(16)
        pv.messageColor = UIColor(white: 0.8, alpha: 1)

        let db = DefaultButton.appearance()
        db.titleColor     = UIColor.white
        db.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        db.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
        
        let cb = CancelButton.appearance()
        cb.titleColor     = UIColor(white: 0.6, alpha: 1)
        cb.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        cb.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
        
        let db2 = DestructiveButton.appearance()
        db2.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        db2.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
    }
}
