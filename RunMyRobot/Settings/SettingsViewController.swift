//
//  SettingsViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 06/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import MXPagerView

struct SettingsStyle {
    struct Nav {
        static let buttonColorActive = UIColor.white
        static let buttonColorInactive = UIColor.white
        static let buttonColorSelected = UIColor.red
    }
}

class SettingsViewController: UIViewController {

    @IBOutlet var pagerView: MXPagerView!
    @IBOutlet var navigationStackView: UIStackView!
    @IBOutlet var navigationIndicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pagerView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changePage(number: 1)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

// MARK: - Navigation Bar
extension SettingsViewController {
    
    func changePage(number: Int) {
        // Get new navigation button
        let newPageButton = navigationStackView.arrangedSubviews[number - 1]
        
        // Move indicator
        self.navigationIndicatorView.snp.remakeConstraints { make in
            make.centerX.equalTo(newPageButton.snp.centerX)
        }
        
        UIView.animate(withDuration: 0.3) {
            // Animate the indicator movement
            self.view.layoutIfNeeded()
            
            // Update the appearance of the button itself
            self.navigationStackView.arrangedSubviews.forEach { button in
                let isCurrent = button.tag == number
                
                button.alpha = isCurrent ? 1 : 0.3
                button.isUserInteractionEnabled = !isCurrent
            }
        }
        
        // Change Page
        pagerView.showPage(at: number - 1, animated: true)
    }
    
    @IBAction func didPressChangePage(_ sender: UIButton) {
        changePage(number: sender.tag)
    }
    
}

// MARK: - Pager
extension SettingsViewController: MXPagerViewDataSource, MXPagerViewDelegate {
    func numberOfPages(in pagerView: MXPagerView) -> Int {
        return navigationStackView.arrangedSubviews.count
    }
    
    func pagerView(_ pagerView: MXPagerView, viewForPageAt index: Int) -> UIView? {
        let provider: SettingsListViewProvider? = {
            switch index {
            case 0:
                return UserSettingsListProvider()
            case 1:
                return NotificationSettingsListProvider()
            case 2:
                return RobotSettingsListProvider(robots: ["Roxi"])
            default:
                return nil
            }
        }()
        
        return SettingsListView(provider: provider)
    }
}
