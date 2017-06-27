//
//  LoginViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 10/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import GSMessages
import MXPagerView

class LoginViewController: UIViewController {
    
    @IBOutlet var returnButton: UIButton!
    @IBOutlet var forgottenButton: UIButton!
    @IBOutlet var newHereButton: UIButton!
    @IBOutlet var notNewButton: UIButton!
    @IBOutlet var pagerView: MXPagerView!
    @IBOutlet var titleLabel: UIButton! // Using a UIButton as it gives a nice fade animation when changing titles
    var startPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pagerView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changePage(startPage, animated: false)
    }
    
    @IBAction func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressPageButton(_ sender: UIButton) {
        changePage(sender.tag, animated: true)
    }
    
    func changePage(_ index: Int, animated: Bool) {
        pagerView.showPage(at: index, animated: animated)
        
        let titles = ["Login", "Register", "Forgotten Password"]
        titleLabel.setTitle(titles[index].uppercased(), for: .disabled)
        
        UIView.animate(withDuration: 0.3) {
            switch index {
            case 0:
                self.returnButton.alpha = 0
                self.forgottenButton.alpha = 1
                self.newHereButton.alpha = 1
                self.notNewButton.alpha = 0
            case 1:
                self.returnButton.alpha = 0
                self.forgottenButton.alpha = 1
                self.newHereButton.alpha = 0
                self.notNewButton.alpha = 1
            case 2:
                self.returnButton.alpha = 1
                self.forgottenButton.alpha = 0
                self.newHereButton.alpha = 1
                self.notNewButton.alpha = 0
            default:
                break
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension LoginViewController: MXPagerViewDataSource, MXPagerViewDelegate {
    
    func numberOfPages(in pagerView: MXPagerView) -> Int {
        return 3
    }
    
    func pagerView(_ pagerView: MXPagerView, viewForPageAt index: Int) -> UIView? {
        switch index {
        case 0:
            return LoginForm.create(parent: self)
        case 1:
            return RegisterForm.create(parent: self)
        case 2:
            return ForgottenPasswordForm.create(parent: self)
        default:
            return nil
        }
    }
    
}
