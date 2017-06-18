//
//  PurchaseRobitsViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 16/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class PurchaseRobitsViewController: UIViewController {

    @IBOutlet var loginView: UIView!
    @IBOutlet var currentRobitCountLabel: UILabel!
    
    class func create() -> PurchaseRobitsViewController {
        let storyboard = UIStoryboard(name: "Modals", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "PurchaseRobits") as? PurchaseRobitsViewController else {
            fatalError()
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = User.current {
            loginView.isHidden = true
            currentRobitCountLabel.text = "You currently have \(user.spendableRobits) robits!"
        } else {
            currentRobitCountLabel.text = ""
        }
    }
    
    @IBAction func didPressPurchase(_ sender: UIButton) {
        guard let user = User.current else {
            didPressLogin()
            return
        }
        
        let product: Payment.Product = sender.tag == 1 ? .robits100 : .robits500
        let robitCount = sender.tag == 1 ? 100 : 500
        
        sender.backgroundColor = sender.tintColor
        let indicator = sender.superview?.viewWithTag(5) as? UIActivityIndicatorView
        indicator?.startAnimating()
        
        user.displayPaymentUI(for: product, viewController: self) { error in
            user.currentPayment = nil
            indicator?.stopAnimating()
            sender.backgroundColor = .clear
            
            if let error = error as? RobotError {
                switch error {
                case .userCancelled:
                    break
                default:
                    print(error)
                    self.view.showMessage("Something went wrong!", type: .error)
                }
                return
            }
            
            self.view.showMessage("\(robitCount) robits purchased successfully!", type: .success)
            user.spendableRobits += robitCount
            self.currentRobitCountLabel.text = "You currently have \(user.spendableRobits) robits!"
        }
    }
    
    @IBAction func didPressLogin() {
        
    }
}
