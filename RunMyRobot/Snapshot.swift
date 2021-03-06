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
    
    static var all = [String: Snapshot]()
    
    var id: String
    var sender: String
    var robotName: String?
    var caption: String
    var image: URL?
    
    init?(_ json: JSON) {
        guard let id = json["snapshot_id"].string,
              let sender = json["username"].string,
              let caption = json["caption"].string,
              let url = json["url"].url else { return nil }
        
        self.id = id
        self.sender = sender
        self.caption = caption
        self.image = url
        
        if let name = json["robot_name"].string {
            self.robotName = name
        }
        
        Snapshot.all[id] = self
    }
    
}
