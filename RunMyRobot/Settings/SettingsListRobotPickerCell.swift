//
//  SettingsListRobotPickerCell.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 06/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import MXPagerView
import TTTAttributedLabel

class SettingsListRobotPickerCell: UITableViewCell {

    @IBOutlet var rightButton: UIButton!
    @IBOutlet var leftButton: UIButton!
    let names = ["TrumpBot", "MadrivaBot", "Gary", "Roxi", "TellyBelly"]
    @IBOutlet var pagerView: MXPagerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        pagerView.dataSource = self
        pagerView.showPage(at: 0, animated: false)
    }
    
    @IBAction func didPressChangeRobot(_ sender: UIButton) {
        var pageNumber = pagerView.indexForSelectedPage
        
        if sender.tag == 1 {
            pageNumber -= 1
        } else {
            pageNumber += 1
        }
        
        pageNumber = max(min(pageNumber, names.count), 0)
        pagerView.showPage(at: pageNumber, animated: true)
        
        leftButton.alpha = pageNumber == 0 ? 0.3 : 1
        rightButton.alpha = pageNumber == names.count - 1 ? 0.3 : 1
    }
}

extension SettingsListRobotPickerCell: MXPagerViewDataSource {
    
    func numberOfPages(in pagerView: MXPagerView) -> Int {
        return 5
    }
    
    func pagerView(_ pagerView: MXPagerView, viewForPageAt index: Int) -> UIView? {
        let label = TTTAttributedLabel(frame: .zero)
        label.kern = 1.8
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        label.setText(names[index])
        return label
    }
    
}
