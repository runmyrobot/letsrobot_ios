//
//  Templating.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import Foundation

extension String {
    
    mutating func replaceTemplateInString(_ template: String, withString: String) {
        self = self.replacingOccurrences(
            of: template, with: withString
        )
    }
    
    mutating func replaceTemplatesInString(_ sources: [(replace: String, with: String)]) {
        for source in sources {
            self.replaceTemplateInString(source.replace, withString: source.with)
        }
    }

}
