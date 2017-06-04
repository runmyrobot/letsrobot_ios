//
//  ChatSettingsView.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

protocol ChatSettingsDelegate: class {
    func didChangeChatFilter(_ selected: Int)
    func didChangeProfanityFilter(_ enabled: Bool)
}

class ChatSettingsView: UIView {
    
    @IBOutlet var profanityFilterSwitch: UISwitch!
    @IBOutlet var chatFilterControl: UISegmentedControl!
    weak var delegate: ChatSettingsDelegate?
    
    class func createView() -> ChatSettingsView {
        let viewNib = UINib(nibName: "ChatSettingsView", bundle: nil)
        let view = viewNib.instantiate(withOwner: self, options: nil).first as! ChatSettingsView
        
        return view
    }

    @IBAction func didChangeProfanityFilter(_ sender: UISwitch) {
        delegate?.didChangeProfanityFilter(sender.isOn)
    }
    
    @IBAction func didChangeChatFilter(_ sender: UISegmentedControl) {
        delegate?.didChangeChatFilter(sender.selectedSegmentIndex)
    }
    
}
