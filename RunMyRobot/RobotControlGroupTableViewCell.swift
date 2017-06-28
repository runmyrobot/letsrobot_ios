//
//  RobotControlGroupTableViewCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 28/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import TagListView

class RobotControlGroupTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tagView: TagListView!
    
    var robot: Robot!
    var panel: ButtonPanel!
    
    /// Timer used to send out continous socket messages when holding down a direction
    var touchDownTimer: Timer?
    
    /// Last direction touched down on, used in conjuction with the timer to send out continous socket messages.
    var touchDownCommand: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        tagView.textFont = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
    }
    
    func setControls(panel: ButtonPanel) {
        self.panel = panel
        
        titleLabel.text = panel.title.uppercased()
        tagView.addTags(panel.buttons.map({ $0.label.lowercased() }))
        
        tagView.tagViews.forEach({
            // Touch Down (Start)
            $0.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
            
            // Touch Up (Release/Cancel/End)
            $0.addTarget(self, action: #selector(touchUp(_:)), for: .touchUpInside)
            $0.addTarget(self, action: #selector(touchUp(_:)), for: .touchUpOutside)
            $0.addTarget(self, action: #selector(touchUp(_:)), for: .touchCancel)
            
            $0.gestureRecognizers?.first(where: { gesture in gesture is UILongPressGestureRecognizer })?.isEnabled = false
        })
    }
    
    func touchDown(_ sender: TagView) {
        guard let senderCommand = command(from: sender) else { return }
        
        // Setup a timer which will be used to send out continous direction requests via the socket
        // This allows the user to hold down a direction and continue moving
        touchDownCommand = senderCommand
        touchDownTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(repeatCommand), userInfo: nil, repeats: true)
        
        Socket.shared.sendDirection(senderCommand, robot: robot, keyPosition: "down")
    }
    
    func touchUp(_ sender: TagView) {
        // Clean up the timer and cancel any future runs
        touchDownTimer?.invalidate()
        touchDownTimer = nil
        touchDownCommand = nil
        
        guard let senderCommand = command(from: sender) else { return }
        Socket.shared.sendDirection(senderCommand, robot: robot, keyPosition: "up")
    }
    
    func repeatCommand() {
        guard let senderCommand = touchDownCommand else { return }
        Socket.shared.sendDirection(senderCommand, robot: robot, keyPosition: "down")
    }
    
    func command(from tagView: TagView) -> String? {
        guard let button = panel.buttons.first(where: { $0.label.lowercased() == tagView.currentTitle }) else { return nil }
        return button.command
    }
    
    func tagView(from senderCommand: String) -> TagView? {
        return tagView.tagViews.first(where: { command(from: $0) == senderCommand })
    }
}
