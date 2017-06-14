//
//  RobotControls.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 14/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import SnapKit

class RobotControls: UIView {

    var robot: Robot!
    
    /// Timer used to send out continous socket messages when holding down a direction
    var touchDownTimer: Timer?
    
    /// Last direction touched down on, used in conjuction with the timer to send out continous socket messages.
    var touchDownDirection: RobotCommand?
    
    class func create(for robot: Robot) -> RobotControls {
        let nib = UINib(nibName: "RobotControls", bundle: nil)
        
        guard let controls = nib.instantiate(withOwner: self, options: nil).first as? RobotControls else {
            fatalError()
        }
        
        controls.robot = robot
        
        for view in controls.subviews {
            guard view is ControlArrowButton else { continue }
            view.backgroundColor = .clear
        }
        
        return controls
    }
    
    func embed(in view: UIView) {
        view.addSubview(self)
        
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        robot.updateControls = { [weak self] in
            Threading.run(on: .main) {
                self?.updateControls()
            }
        }
    }
    
    func updateControls() {
        for view in subviews {
            guard view is ControlArrowButton else { continue }
            guard let buttonCommand = command(from: view.tag) else { continue }
            view.layer.borderColor = UIColor.white.cgColor
            
            switch buttonCommand {
            case .forward:
                view.layer.borderWidth = robot.currentCommand == RobotCommand.forward.rawValue ? 2 : 0
            case .backward:
                view.layer.borderWidth = robot.currentCommand == RobotCommand.backward.rawValue ? 2 : 0
            case .left:
                view.layer.borderWidth = robot.currentCommand == RobotCommand.left.rawValue ? 2 : 0
            case .right:
                view.layer.borderWidth = robot.currentCommand == RobotCommand.right.rawValue ? 2 : 0
            default:
                break
            }
        }
    }
    
    @IBAction func didPressDirection(_ sender: UIButton) {
        guard let direction = command(from: sender.tag) else { return }
        
        // Setup a timer which will be used to send out continous direction requests via the socket
        // This allows the user to hold down a direction and continue moving
        touchDownDirection = direction
        touchDownTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(didHoldDirection), userInfo: nil, repeats: true)
        
        Socket.shared.sendDirection(direction, robot: robot, keyPosition: "down")
    }
    
    @IBAction func didReleaseDirection(_ sender: UIButton) {
        guard let direction = command(from: sender.tag) else { return }
        
        // Clean up the timer and cancel any future runs
        touchDownTimer?.invalidate()
        touchDownTimer = nil
        touchDownDirection = nil
        
        Socket.shared.sendDirection(direction, robot: robot, keyPosition: "up")
    }
    
    func didHoldDirection() {
        guard let direction = touchDownDirection else { return }
        Socket.shared.sendDirection(direction, robot: robot, keyPosition: "down")
    }
    
    func command(from tag: Int) -> RobotCommand? {
        switch tag {
        case 1:
            return .forward
        case 2:
            return .backward
        case 3:
            return .left
        case 4:
            return .right
        default:
            return nil
        }
    }

}
