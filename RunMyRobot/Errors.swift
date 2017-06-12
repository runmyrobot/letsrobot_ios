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
    case requestFailure(original: Error)
}
