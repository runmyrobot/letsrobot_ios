//
//  ControlArrowButton.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class ControlArrowButton: UIButton {
    
    var arrowDirection: String?
    
    override func draw(_ rect: CGRect) { // swiftlint:disable:this function_body_length
        
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        switch arrowDirection ?? "right" {
        case "right":
            let p1 = CGPoint(x: 0, y: 0)
            let p2 = CGPoint(x: rect.width * 0.56, y: 0)
            let p3 = CGPoint(x: rect.width - 5, y: rect.height / 2)
            let p4 = CGPoint(x: rect.width * 0.56, y: rect.height)
            let p5 = CGPoint(x: 0, y: rect.height)
            
            path.move(to: p1)
            path.addLine(to: p2)
            path.addLine(to: p3)
            path.addLine(to: p4)
            path.addLine(to: p5)
        case "up":
            let p1 = CGPoint(x: rect.width / 2, y: 5)
            let p2 = CGPoint(x: rect.width, y: rect.height * 0.44)
            let p3 = CGPoint(x: rect.width, y: rect.height)
            let p4 = CGPoint(x: 0, y: rect.height)
            let p5 = CGPoint(x: 0, y: rect.height * 0.44)
            
            path.move(to: p1)
            path.addLine(to: p2)
            path.addLine(to: p3)
            path.addLine(to: p4)
            path.addLine(to: p5)
        case "down":
            let p1 = CGPoint(x: 0, y: 0)
            let p2 = CGPoint(x: rect.width, y: 0)
            let p3 = CGPoint(x: rect.width, y: rect.height * 0.56)
            let p4 = CGPoint(x: rect.width / 2, y: rect.height - 5)
            let p5 = CGPoint(x: 0, y: rect.height * 0.56)
            
            path.move(to: p1)
            path.addLine(to: p2)
            path.addLine(to: p3)
            path.addLine(to: p4)
            path.addLine(to: p5)
        default: // left
            let p1 = CGPoint(x: 5, y: rect.height / 2)
            let p2 = CGPoint(x: rect.width * 0.44, y: 0)
            let p3 = CGPoint(x: rect.width, y: 0)
            let p4 = CGPoint(x: rect.width, y: rect.height)
            let p5 = CGPoint(x: rect.width * 0.44, y: rect.height)
            
            path.move(to: p1)
            path.addLine(to: p2)
            path.addLine(to: p3)
            path.addLine(to: p4)
            path.addLine(to: p5)
        }
        
        path.close()
        
        UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1).setFill()
        path.fill()
        
        UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1).setStroke()
        path.lineWidth = 5
        path.stroke()
    }

}
