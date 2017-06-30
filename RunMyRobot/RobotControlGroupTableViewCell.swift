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
    weak var parentView: RobotControls?
    
    /// Timer used to send out continous socket messages when holding down a direction
    var touchDownTimer: Timer?
    
    /// Last direction touched down on, used in conjuction with the timer to send out continous socket messages.
    var touchDownButton: ButtonPanel.Button?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        tagView.textFont = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
    }
    
    func setControls(panel: ButtonPanel) {
        self.panel = panel
        
        titleLabel.text = panel.title.uppercased()
        tagView.addTags(panel.buttons.map({
            title(for: $0) ?? ""
        }))
        
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
        guard let senderButton = button(from: sender) else { return }
        
        // If the command is premium then we don't want to have "hold to repeat" functionality.
        if senderButton.isPremium {
            guard User.current?.canAffordPremiumCommand(senderButton) == true else {
                parentView?.showMessage("You can't afford this premium command!", type: .error)
                return
            }
        } else {
            // Setup a timer which will be used to send out continous direction requests via the socket
            // This allows the user to hold down a direction and continue moving
            touchDownButton = senderButton
            touchDownTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(repeatCommand), userInfo: nil, repeats: true)
        }
        
        Socket.shared.sendDirection(senderButton, robot: robot, keyPosition: "down")
    }
    
    func touchUp(_ sender: TagView) {
        // Clean up the timer and cancel any future runs
        touchDownTimer?.invalidate()
        touchDownTimer = nil
        touchDownButton = nil
        
        // Premium commands are only done on key-down events!
        guard let senderButton = button(from: sender), !senderButton.isPremium else { return }
        Socket.shared.sendDirection(senderButton, robot: robot, keyPosition: "up")
    }
    
    func repeatCommand() {
        guard let senderButton = touchDownButton else { return }
        Socket.shared.sendDirection(senderButton, robot: robot, keyPosition: "down")
    }
    
    func command(from tagView: TagView) -> String? {
        return button(from: tagView)?.command
    }
    
    func tagView(from senderCommand: String) -> TagView? {
        return tagView.tagViews.first(where: { command(from: $0) == senderCommand })
    }
    
    func button(from tagView: TagView) -> ButtonPanel.Button? {
        return panel.buttons.first(where: { title(for: $0) == tagView.currentTitle })
    }
    
    func title(for button: ButtonPanel.Button) -> String? {
        guard button.isPremium else {
            return button.label.lowercased()
        }
        
        // Premium UI is temporary
        return button.label.lowercased() + (button.isPremium ? " - \(button.price)r" : "")
    }
}
