//
//  AngledView.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 31/05/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

/// Creates a basic right angled triangle view of the given color
class AngledView: UIView {
    
    var angleColor: UIColor = .red {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var shadowColor: UIColor = .white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        let p1 = CGPoint(x: bounds.width, y: 5)
        let p2 = CGPoint(x: bounds.width, y: bounds.height)
        let p3 = CGPoint(x: 0, y: bounds.height)
        
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.close()
        
        angleColor.set()
        path.fill()
        
        
        let p4 = CGPoint(x: 0, y: bounds.height)
        let p5 = CGPoint(x: bounds.width, y: 5)
        
        let shadow = UIBezierPath()
        shadow.move(to: p4)
        shadow.addLine(to: p5)
        shadow.close()
        
        shadowColor.set()
        shadow.stroke()
        
        layer.shadowRadius = 4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
}
