//
//  RulesViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 10/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class RulesViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: "Rules", withExtension: "html") {
            if let contents = try? String(contentsOf: url, encoding: .utf8) {
                webView.loadHTMLString(contents, baseURL: nil)
            }
        }
    }

    @IBAction func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
