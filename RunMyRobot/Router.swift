//
//  Router.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 29/06/2017.
//  Copyright © 2017 Let's Robot. All rights reserved.
//

import UIKit
import Crashlytics

protocol Navigatable: class {
    static var navigationRegex: String { get }
    static func create(info: [String]) -> UIViewController
}

class Router {
    
    var postponeURL: URL?
    
    static let routes: [Navigatable.Type] = [
        LoginRoute.self,
        RegisterRoute.self,
        RobotRoute.self
//        RobotProfileRoute.self - Coming Soon
//        UserProfileRoute.self - Coming Soon
    ]
    
    @discardableResult
    func handle(_ url: URL, source: String? = nil) -> Bool {
        print("Handle \(url.absoluteString) from source: \(source)")
        
        guard let foundRoute = route(for: url) else {
            print("NO ROUTE FOUND")
            return false
        }
        
        let postpone = AppDelegate.current?.postponeLinks == true
        
        if postponeURL == nil {
            Answers.logCustomEvent(withName: "Router", customAttributes: [
                "route": String(describing: foundRoute.route),
                "postponed": postpone,
                // TODO: Make this detect universal linking, and change source to say "site"
                "source_app": source ?? "Unknown"
            ])
        }
        
        if postpone {
            postponeURL = url
            return true
        }
        
        postponeURL = nil
        
        let viewController = foundRoute.route.create(info: foundRoute.info)
        Socket.shared.viewController?.present(viewController, animated: true, completion: nil)
        
        return true
    }
    
    func route(for url: URL) -> (route: Navigatable.Type, info: [String])? {
        for route in Router.routes {
            if let info = url.absoluteString.matches(pattern: route.navigationRegex).first {
                return (route, info)
            }
        }
        
        return nil
    }
    
    class fileprivate func viewController(identifier: String, storyboard: String = "Main") -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}

class LoginRoute: Navigatable {
    static var navigationRegex: String { return "(login)" }
    
    static func create(info: [String]) -> UIViewController {
        return Router.viewController(identifier: "Login")
    }
}

class RegisterRoute: Navigatable {
    static var navigationRegex: String { return "(register)" }
    
    static func create(info: [String]) -> UIViewController {
        guard let vc = LoginRoute.create(info: info) as? LoginViewController else {
            fatalError()
        }
        
        vc.startPage = 1
        
        return vc
    }
}

class RobotRoute: Navigatable {
    static var navigationRegex: String { return "robot\\/(\\d+)" }
    
    static func create(info: [String]) -> UIViewController {
        guard let vc = Router.viewController(identifier: "RobotStream") as? StreamViewController else {
            fatalError()
        }
        
        if let robotId = info.first, let robot = Robot.get(id: robotId) {
            vc.robot = robot
        }
        
        return vc
    }
}

class RobotProfileRoute: Navigatable {
    static var navigationRegex: String { return "robot_profile\\/(\\d+)" }
    
    static func create(info: [String]) -> UIViewController {
        fatalError()
    }
}

class UserProfileRoute: Navigatable {
    static var navigationRegex: String { return "user\\/([a-zA-Z0-9_-]+)" }
    
    static func create(info: [String]) -> UIViewController {
        fatalError()
    }
}
