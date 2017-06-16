//
//  User+Payments.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 16/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Alamofire
import SwiftyJSON
import Braintree
import BraintreeDropIn

extension User {
    
    /// Requests a new BrainTree client token for payments
    private func getClientPaymentToken(callback: @escaping ((String?, Error?) -> Void)) {
        Networking.requestJSON("/internal/braintree/token") { response in
            if let error = response.error {
                callback(nil, RobotError.requestFailure(original: error))
                return
            }
            
            guard let data = response.data else {
                callback(nil, RobotError.noData)
                return
            }
            
            let json = JSON(data)
            
            guard let token = json["client_token"].string else {
                callback(nil, RobotError.parseFailure)
                return
            }
            
            callback(token, nil)
        }
    }
    
    /// Asyncronously fetches a new client token, and then returns a BTDropInController with that token
    private func getPaymentDropIn(handler: @escaping BTDropInControllerHandler, callback: @escaping ((BTDropInController?, Error?) -> Void)) {
        // BrainTree recommend a new payment token for every "user checkout session". I'm not sure, for us, if this means
        // every payment or just every session within the application.
        //
        // This method can be quite easily refactored to store tokens per session.
        
        getClientPaymentToken { (token, error) in
            if let error = error {
                callback(nil, error)
                return
            }
            
            guard let token = token else {
                callback(nil, RobotError.noData)
                return
            }
            
            callback(self.getPaymentDropIn(token: token, handler: handler), nil)
        }
    }
    
    /// Creates and attempts to return a BTDropInController with the provided client payment token
    private func getPaymentDropIn(token: String, handler: @escaping BTDropInControllerHandler) -> BTDropInController? {
        let request = BTDropInRequest()
        return BTDropInController(authorization: token, request: request, handler: handler)
    }
    
    func displayPaymentDropIn(_ viewController: UIViewController, callback: @escaping ((Error?) -> Void)) {
        let controllerHandler: BTDropInControllerHandler = { (controller, result, error) in
            print("oops something went wrong")
        }
        
        getPaymentDropIn(handler: controllerHandler) { (controller, error) in
            if let error = error {
                callback(error)
                return
            }
            
            guard let controller = controller else {
                callback(RobotError.noData)
                return
            }
            
            viewController.present(controller, animated: true, completion: nil)
        }
    }
}
