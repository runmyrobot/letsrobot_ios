//
//  Snapshot.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 15/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation
import SwiftyJSON

class Snapshot {
    
    var sender: String
    var robotName: String
    var caption: String
    var image: URL?
    
    init?(_ json: JSON) {
        guard let sender = json["username"].string,
              let robotName = json["robot_name"].string,
              let caption = json["caption"].string else { return nil }
        
        self.sender = sender
        self.robotName = robotName
        self.caption = caption
        self.image = URL(string: "")
    }
    
}
