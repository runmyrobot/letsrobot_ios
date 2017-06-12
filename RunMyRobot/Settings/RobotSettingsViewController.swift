//
//  RobotSettingsViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 11/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import MXPagerView
import GSMessages

class RobotSettingsViewController: UIViewController {

    @IBOutlet var saveRobotsIndicator: UIActivityIndicatorView!
    @IBOutlet var saveRobotsButton: UIButton!
    @IBOutlet var pageRightButton: UIButton!
    @IBOutlet var pageLeftButton: UIButton!
    @IBOutlet var robotPickerPagerView: MXPagerView!
    @IBOutlet var pagerView: MXPagerView!
    var robots: [Robot]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        robotPickerPagerView.isScrollEnabled = false
        pagerView.isScrollEnabled = false
        saveRobotsButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showPage(0, animate: false)
    }

    @IBAction func didPressClose() {
        let unsavedChanges = robots.filter { $0.unsavedChanges.count > 0 }
        
        if unsavedChanges.count == 0 {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: "Are you sure?", message: "One or more of your robots have unsaved changes!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Revert Changes", style: .destructive, handler: { _ in
            self.robots.forEach {
                $0.unsavedChanges.removeAll()
            }
            
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didPressSave() {
        view.endEditing(true)
        
        saveRobotsButton.isHidden = true
        saveRobotsIndicator.startAnimating()
        
        User.current?.saveRobots { error in
            self.saveRobotsButton.isHidden = false
            self.saveRobotsIndicator.stopAnimating()
            
            if error != nil {
                self.saveRobotsButton.isEnabled = true
                self.showMessage("Something went wrong!", type: .error)
                return
            }
            
            self.saveRobotsButton.isEnabled = false
            self.showMessage("All Robots Saved!", type: .success)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
            let provider = RobotSettingsListProvider(robots[index], segueController: self, changeCallback: {
                self.saveRobotsButton.isEnabled = true
            })
            
            return SettingsListView(provider: provider)
        }
        
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = robots[index].name
        return label
    }
    
}
