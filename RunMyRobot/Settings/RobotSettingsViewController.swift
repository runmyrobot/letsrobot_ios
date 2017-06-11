//
//  RobotSettingsViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 11/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import MXPagerView

class RobotSettingsViewController: UIViewController {

    @IBOutlet var pageRightButton: UIButton!
    @IBOutlet var pageLeftButton: UIButton!
    @IBOutlet var robotPickerPagerView: MXPagerView!
    @IBOutlet var pagerView: MXPagerView!
    var robots: [Robot]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        robotPickerPagerView.isScrollEnabled = false
        pagerView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showPage(0, animate: false)
    }

    @IBAction func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressSave() {
        // Save all robots
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showPage(_ index: Int, animate: Bool) {
        pagerView.showPage(at: index, animated: animate)
        robotPickerPagerView.showPage(at: index, animated: animate)
        pageLeftButton.isEnabled = index != 0
        pageRightButton.isEnabled = index != robots.count - 1
    }
    
    @IBAction func didPressChangePage(_ sender: UIButton) {
        let current = pagerView.indexForSelectedPage
        if sender.tag == 1 {
            showPage(current - 1, animate: true)
        } else if sender.tag == 2 {
            showPage(current + 1, animate: true)
        }
    }
}

extension RobotSettingsViewController: MXPagerViewDataSource, MXPagerViewDelegate {
    
    func numberOfPages(in pagerView: MXPagerView) -> Int {
        return robots.count
    }
    
    func pagerView(_ pagerView: MXPagerView, viewForPageAt index: Int) -> UIView? {
        if pagerView == self.pagerView {
            return SettingsListView(provider: RobotSettingsListProvider(robots[index]))
        }
        
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = robots[index].name
        return label
    }
    
}
