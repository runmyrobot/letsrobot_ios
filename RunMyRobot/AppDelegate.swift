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
import Braintree
import AVFoundation
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CrashlyticsDelegate, OSPermissionObserver {

    var appId: String?
    var window: UIWindow?
    var router = Router()
    var postponeLinks = true
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // BrainTree Payments
        BTAppSwitch.setReturnURLScheme("tv.letsrobot.client.ios.payments")
        
        // Crashlytics & Fabric
        Crashlytics.sharedInstance().delegate = self
        Fabric.with([Crashlytics.self])
        
        // Push Notifications
        setupPushNotifications(launchOptions)
        
        // Audio Settings
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        // Some things can be done on background thread as to not lock up the launching
        Threading.run(on: .background, after: 0) {
            self.setupDefaultAlert()
        }
        
        if let url = launchOptions?[.url] as? URL {
            return router.handle(url, source: launchOptions?[.sourceApplication] as? String)
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare("tv.letsrobot.client.ios.payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        
        return router.handle(url, source: options[.sourceApplication] as? String)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else { return false }
        guard let url = userActivity.webpageURL else { return false }
        
        return router.handle(url, source: "continueUserActivity")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        UserDefaults.standard.lastActive = Date().timeIntervalSince1970
        Crashlytics.sharedInstance().setFloatValue(Float(UserDefaults.standard.lastActive), forKey: "lastActive")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        let lastActive = Date(timeIntervalSince1970: UserDefaults.standard.lastActive)
        let checkDate = Date(timeIntervalSinceNow: -3600) // An hour ago (3600 seconds)
        
        if lastActive < checkDate {
            fabricLog("Force Bootloader")
            
            if let window = window {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                window.rootViewController = storyboard.instantiateInitialViewController()
            }
        }
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
    
    func crashlyticsDidDetectReport(forLastExecution report: CLSReport, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(UserDefaults.standard.sendCrashReports)
    }
    
    func openAppStore(action: String? = nil) {
        guard let appId = appId else { return }
        
        let actionUrl: String = {
            if let action = action {
                return "?action=\(action)"
            }
            
            return ""
        }()
        
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appId)\(actionUrl)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func setupPushNotifications(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        let oneSignalInitSettings = [kOSSettingsKeyAutoPrompt: true,
                                     kOSSettingsKeyInAppLaunchURL: true,
                                     kOSSettingsKeyInAppAlerts: false]
        
        let notificationReceived: OSHandleNotificationReceivedBlock = { notification in
            print(notification?.payload.title ?? "Unknown Title")
        }
        
        let notificationActioned: OSHandleNotificationActionBlock = { result in
            // Need to work out how to detect the URL from the payload.
            print(result?.notification.payload.launchURL ?? "hmm")
            print(result?.notification.payload.title ?? "Unknown Title")
        }
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "db6a356a-83f6-4cc5-b751-3b54978a8f67",
                                        handleNotificationReceived: notificationReceived,
                                        handleNotificationAction: notificationActioned,
                                        settings: oneSignalInitSettings)
        
        OneSignal.inFocusDisplayType = .notification
        OneSignal.add(self as OSPermissionObserver)
    }
    
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        let authorised = OneSignal.getPermissionSubscriptionState().permissionStatus.status == .authorized
        Crashlytics.sharedInstance().setBoolValue(authorised, forKey: "notifications_authorised")
    }
}

extension AppDelegate {
    
    static var current: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    var appBuild: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
    
    var currentVersionDescription: String? {
        guard let version = appVersion, let build = appBuild else { return nil }
        return "Version \(version), Build \(build)"
    }
    
}

func fabricLog(_ message: String) {
    CLSLogv("%@", getVaList([message]))
}
