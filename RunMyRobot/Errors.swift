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
    case apiFailure(message: String)
    case parseFailure
    case inconsistencyException
    case noCurrentPayment
    case existingPayment
    case userCancelled
    case noPaymentNonce
    case requestFailure(original: Error)
    
    /// User readable description
    var localizedDescription: String {
        switch self {
        case .notLoggedIn:
            return "You must be logged in!"
        case .invalidLoginDetails:
            return "Incorrect Login Details! Try again."
        default:
            return "Something went wrong!"
        }
    }
    
    /// Used by debugger to work out, in a bit more of a friendly way, which error it is!
    var actualError: String {
        switch self {
        case .notLoggedIn:
            return "User not logged in"
        case .invalidLoginDetails:
            return "Invalid Login Details"
        case .noData:
            return "API returned no parsable data"
        case .apiFailure(let message):
            return "API returned an error message: \(message)"
        case .parseFailure:
            return "API returned data that didn't match known keypaths"
        case .inconsistencyException:
            return "API returned value which was didn't match expected values"
        case .noCurrentPayment:
            return "Payment was trying to finish, but there is no current payment!"
        case .existingPayment:
            return "Payment was attempted whilst another one is already happening!"
        case .userCancelled:
            return "Payment was cancelled by the user!"
        case .noPaymentNonce:
            return "Payment did not return a nonce!"
        case .requestFailure(let original):
            return original.localizedDescription
        }
    }
}
