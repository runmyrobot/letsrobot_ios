//
//  Payment.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 16/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import SwiftyJSON

class Product {
    static var all = [String: Product]()
    static let priceToDollarMultiplier = 0.01
    
    var name: String
    private var priceRaw: Double
    var type: String
    var robitCount: Int?
    
    var price: String {
        let raw = priceRaw * Product.priceToDollarMultiplier
        return String(format: "%.2f", raw)
    }
    
    init?(_ json: JSON) {
        guard let name = json["name"].string,
            let price = json["price"].double,
            let type = json["type"].string else { return nil }
        
        self.name = name
        self.priceRaw = price
        self.type = type
        self.robitCount = json["amount_of_robits"].int
        Product.all[name] = self
    }
    
    var nonceEndpoint: String {
        return "/internal/braintree/\(name)/nonce"
    }
    
}

class Payment {
    
    var product: Product
    
    // Used for xcontrol purchases
    var robotId: String?
    
    init(product: Product, robotId: String? = nil) {
        self.product = product
    }
    
}
