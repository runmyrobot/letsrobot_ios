//
//  SettingsViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 06/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import MXPagerView
import PopupDialog

class SettingsViewController: UIViewController {

    @IBOutlet var saveUserIndicator: UIActivityIndicatorView!
    @IBOutlet var saveUserButton: UIButton!
    @IBOutlet var pagerView: MXPagerView!
    @IBOutlet var navigationStackView: UIStackView!
    @IBOutlet var navigationIndicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pagerView.isScrollEnabled = false
        saveUserButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changePage(number: 1, animate: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func didPressSave() {
        view.endEditing(true)
        
        saveUserButton.isHidden = true
        saveUserIndicator.startAnimating()
        
        User.current?.saveProfile { error in
            self.saveUserButton.isHidden = false
            self.saveUserIndicator.stopAnimating()
            
            if error != nil {
                self.saveUserButton.isEnabled = true
                self.showMessage("Something went wrong!", type: .error)
                return
            }
            
            self.saveUserButton.isEnabled = false
            self.showMessage("All Robots Saved!", type: .success)
        }
    }
    
    @IBAction func didPressClose() {
        view.endEditing(true)
        
        if (User.current?.unsavedChanges.count ?? 0) > 0 {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let popup = PopupDialog(title: "Are you sure?", message: "Your profile has unsaved changes!", transitionStyle: .zoomIn)
        
        let cancel = CancelButton(title: "Cancel", action: nil)
        let revert = DestructiveButton(title: "Revert Changes") {
            User.current?.unsavedChanges.removeAll()
            
            self.dismiss(animated: true, completion: nil)
        }
        
        popup.addButtons([revert, cancel])
        present(popup, animated: true, completion: nil)
    }
}

// MARK: - Navigation Bar
extension SettingsViewController {
    
    func changePage(number: Int, animate: Bool = true) {
        // Get new navigation button
        let newPageButton = navigationStackView.arrangedSubviews[number - 1]
        
        // Move indicator
        self.navigationIndicatorView.snp.remakeConstraints { make in
            make.centerX.equalTo(newPageButton.snp.centerX)
        }
        
        UIView.animate(withDuration: animate ? 0.3 : 0) {
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
        pagerView.showPage(at: number - 1, animated: animate)
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
                return UserSettingsListProvider(changeCallback: {
                    self.saveUserButton.isEnabled = true
                })
            case 1:
                return SubscriptionsListProvider()
            default:
                return nil
            }
        }()
        
        return SettingsListView(provider: provider)
    }
}
