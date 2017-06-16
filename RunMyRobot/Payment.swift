//
//  Payment.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 16/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation

class Payment {
    
    enum Product {
        case xcontrol(String)
        case robits100
        case robits500
        
        var price: String {
            switch self {
            case .xcontrol(_):
                return "0.50"
            case .robits100:
                return "1.40"
            case .robits500:
                return "7.00"
            }
        }
        
        var nonceEndpoint: String {
            switch self {
            case .xcontrol(_):
                return "/internal/braintree/xcontrol/nonce"
            case .robits100:
                return "/internal/braintree/robits100/nonce"
            case .robits500:
                return "/internal/braintree/robits500/nonce"
            }
        }
    }
    
    var product: Product
    
    init(product: Product) {
        self.product = product
    }
    
}
