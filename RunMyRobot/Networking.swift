//
//  Networking.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 10/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation
import Alamofire

class Networking {
    
    static let baseUrl = "https://runmyrobot.com"
    
    static func request(_ url: String,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: HTTPHeaders? = nil,
                        completion: @escaping ((DefaultDataResponse) -> Void)) {
        
        Alamofire.request(
            baseUrl + url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        ).response(completionHandler: completion)
    }
    
    static func requestJSON(_ url: String,
                            method: HTTPMethod = .get,
                            parameters: Parameters? = nil,
                            encoding: ParameterEncoding = URLEncoding.default,
                            headers: HTTPHeaders? = nil,
                            completion: @escaping ((DataResponse<Any>) -> Void)) {
        
        Alamofire.request(
            baseUrl + url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        ).responseJSON(completionHandler: completion)
    }
    
}
