//
//  PurchaseRobitsViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 16/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import GMStepper

class PurchaseRobitsViewController: UIViewController {

    @IBOutlet var sendWootsButton: UIButton!
    @IBOutlet var pagePicker: UISegmentedControl!
    @IBOutlet var robitStepper: GMStepper!
    @IBOutlet var pageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var paymentTwoAmountLabel: UILabel!
    @IBOutlet var paymentTwoPriceLabel: UILabel!
    @IBOutlet var paymentOneAmountLabel: UILabel!
    @IBOutlet var paymentOnePriceLabel: UILabel!
    @IBOutlet var loginView: UIView!
    @IBOutlet var currentRobitCountLabel: UILabel!
    
    var robot: Robot!
    var products = [Product]()
    var pendingTransaction: Int?
    
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
        
        if (User.current?.spendableRobits ?? 0) > 0 {
            pageLeadingConstraint.isActive = false
        } else {
            pagePicker.selectedSegmentIndex = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        User.current?.updateRobits = { [weak self] diff in
            guard let user = User.current else { return }
            
            if let amount = self?.pendingTransaction {
                if amount == diff {
                    let pluralise = amount > 1 ? "woots" : "woot"
                    self?.view.showMessage("\(amount) \(pluralise) sent successfully!", type: .success)
                } else {
                    self?.view.showMessage("Something went wrong!", type: .error)
                }
                
                self?.pendingTransaction = nil
                self?.sendWootsButton.isEnabled = true
            }
            
            self?.currentRobitCountLabel.text = "You currently have \(user.spendableRobits) robits!"
            
            let current = self?.robitStepper.value ?? 10
            self?.robitStepper.value = min(current, Double(user.spendableRobits))
            self?.robitStepper.maximumValue = Double(user.spendableRobits)
        }
    }
    
    deinit {
        User.current?.updateRobits = nil
    }
    
    func updateLoginStatus() {
        if let user = User.current {
            loginView.isHidden = true
            currentRobitCountLabel.text = "You currently have \(user.spendableRobits) robits!"
            robitStepper.value = Double(min(10, user.spendableRobits))
            robitStepper.maximumValue = Double(user.spendableRobits)
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
        }
    }
    
    @IBAction func didChangePage(_ sender: UISegmentedControl) {
        guard User.current != nil else { return }
        pageLeadingConstraint.isActive = sender.selectedSegmentIndex != 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func didPressSend() {
        guard robitStepper.value > 0 else {
            view.showMessage("You can't send 0 woots!", type: .error)
            return
        }
        
        let robits = Int(robitStepper.value)
        
        guard let owner = robot.owner else {
            view.showMessage("Something went wrong!", type: .error)
            return
        }
        
        guard robits <= (User.current?.spendableRobits ?? 0) else {
            view.showMessage("You don't have enough robits!", type: .error)
            return
        }
        
        pendingTransaction = robits
        
//        Socket.shared.chat.sendMessage("woot\(robits)", robot: robot)
        Socket.shared.sendRobits(amount: robits, recipient: owner)
        sendWootsButton.isEnabled = false
    }
    
    @IBAction func didPressLogin() {
        performSegue(withIdentifier: "ShowLogin", sender: nil)
    }
}
