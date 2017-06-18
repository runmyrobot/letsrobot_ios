//
//  PurchaseRobitsViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 16/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class PurchaseRobitsViewController: UIViewController {

    @IBOutlet var paymentTwoAmountLabel: UILabel!
    @IBOutlet var paymentTwoPriceLabel: UILabel!
    @IBOutlet var paymentOneAmountLabel: UILabel!
    @IBOutlet var paymentOnePriceLabel: UILabel!
    @IBOutlet var loginView: UIView!
    @IBOutlet var currentRobitCountLabel: UILabel!
    
    var products = [Product]()
    
    class func create() -> PurchaseRobitsViewController {
        let storyboard = UIStoryboard(name: "Modals", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "PurchaseRobits") as? PurchaseRobitsViewController else {
            fatalError()
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(updateLoginStatus), name: NSNotification.Name("LoginStatusChanged"), object: nil)
        updateLoginStatus()
        
        var robitProducts = Product.all.values.filter({ $0.type.lowercased() == "robits" }).prefix(2)
        if let product = robitProducts.popFirst() { products.append(product) }
        if let product = robitProducts.popFirst() { products.append(product) }
        
        updateProducts()
    }
    
    func updateLoginStatus() {
        if let user = User.current {
            loginView.isHidden = true
            currentRobitCountLabel.text = "You currently have \(user.spendableRobits) robits!"
        } else {
            loginView.isHidden = false
            currentRobitCountLabel.text = ""
        }
    }
    
    func updateProducts() {
        guard products.count == 2 else { return }
        
        let productOne = products[0]
        paymentOnePriceLabel.text = "$\(productOne.price)"
        paymentOneAmountLabel.text = "Buy \(productOne.robitCount ?? 0) Robits"
        
        let productTwo = products[1]
        paymentTwoPriceLabel.text = "$\(productTwo.price)"
        paymentTwoAmountLabel.text = "Buy \(productTwo.robitCount ?? 0) Robits"
    }
    
    @IBAction func didPressPurchase(_ sender: UIButton) {
        guard let user = User.current else {
            didPressLogin()
            return
        }
        
        guard products.count == 2 else {
            view.showMessage("Something went wrong!", type: .error)
            return
        }
        
        let product = products[sender.tag - 1]
        let robitCount = product.robitCount ?? 0
        
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
            self.currentRobitCountLabel.text = "You currently have \(user.spendableRobits) robits!"
        }
    }
    
    @IBAction func didPressLogin() {
        performSegue(withIdentifier: "ShowLogin", sender: nil)
    }
}
