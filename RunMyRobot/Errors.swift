//
//  Errors.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation

enum RobotError: Error {
    case notLoggedIn
    case invalidLoginDetails
    case noData
    case apiFailure
    case parseFailure
    case inconsistencyException
    case noCurrentPayment
    case existingPayment
    case userCancelled
    case noPaymentNonce
    case requestFailure(original: Error)
    
    var localizedDescription: String {
        switch self {
        case .notLoggedIn:
            return "You must be logged in!"
        case .invalidLoginDetails:
            return "Incorrect Login Details! Try again."
        case .requestFailure(let original):
            return original.localizedDescription
        default:
            return "Something went wrong!"
        }
    }
}
