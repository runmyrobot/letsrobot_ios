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

extension CurrentUser {
    
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
    
    private func postNonce(_ nonce: String, callback: @escaping ((Error?) -> Void)) {
        guard let payment = currentPayment else {
            callback(RobotError.noCurrentPayment)
            return
        }
        
        var payload: Parameters = [
            "amount": payment.product.price,
            "nonce": nonce
        ]
        
        if case let Payment.Product.xcontrol(robotId) = payment.product {
            payload["robot_id"] = robotId
        }
        
        Networking.request(payment.product.nonceEndpoint, method: .post, parameters: payload) { response in
            if let error = response.error {
                callback(RobotError.requestFailure(original: error))
                return
            }
            
            guard let data = response.data else {
                callback(RobotError.noData)
                return
            }
            
            let json = JSON(data)
            
            // End of the chain!
            // If this returns nil, then it is classified as a successful payment
            callback(nil)
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
        request.amount = currentPayment?.product.price
        
        return BTDropInController(authorization: token, request: request, handler: handler)
    }
    
    private func displayPaymentDropIn(_ viewController: UIViewController, callback: @escaping ((Error?) -> Void)) {
        let controllerHandler: BTDropInControllerHandler = { (controller, result, error) in
            if let error = error {
                callback(RobotError.requestFailure(original: error))
            } else if result?.isCancelled == true {
                callback(RobotError.userCancelled)
            } else if let result = result {
                if let nonce = result.paymentMethod?.nonce {
                    self.postNonce(nonce, callback: callback)
                } else {
                    callback(RobotError.noPaymentNonce)
                }
            }
            
            controller.dismiss(animated: true, completion: nil)
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
            
            Threading.run(on: .main) {
                viewController.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func displayPaymentUI(for product: Payment.Product, viewController: UIViewController, callback: @escaping ((Error?) -> Void)) {
        if currentPayment != nil {
            callback(RobotError.existingPayment)
            return
        }
        
        currentPayment = Payment(product: product)
        displayPaymentDropIn(viewController, callback: callback)
    }
}
