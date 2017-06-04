//
//  StreamViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 31/05/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import ReverseExtension

class StreamViewController: UIViewController {

    // Camera
    @IBOutlet var cameraContainerView: UIView!
    @IBOutlet var cameraWebView: UIWebView!
    @IBOutlet var cameraLoadingView: UIView!
    @IBOutlet var cameraErrorLabel: UILabel!
    @IBOutlet var cameraOverlayView: UIView!
    
    // Chat
    @IBOutlet var chatTextField: UITextField!
    @IBOutlet var chatTableView: UITableView!
//    @IBOutlet var chatFilterControl: UISegmentedControl!
    
    // Controls
    @IBOutlet var controlContainerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var viewCountLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var ownerLabel: UILabel!
    
    // Loading View
    @IBOutlet var loadingViewContainer: UIView!
    @IBOutlet var loadingMessageLabel: UILabel!
    
    // Subscribe
    @IBOutlet var subscribeButton: UIButton!
    @IBOutlet var subscriberCountLabel: UILabel!
    @IBOutlet var subscriberCountContainerView: UIView!
    
    // Constraints
    @IBOutlet var gameIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var chatBoxTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var viewSwapperBottomConstraint: NSLayoutConstraint!
    @IBOutlet var titleVerticalConstraint: NSLayoutConstraint!
    
    /// Timer used to send out continous socket messages when holding down a direction
    var touchDownTimer: Timer?
    
    /// Last direction touched down on, used in conjuction with the timer to send out continous socket messages.
    var touchDownDirection: RobotCommand?
    
    /// Current robot, as set from the Robot Chooser segue
    var robot: Robot!
    
    /// The current view shown to the user: 1 is Chat, 2 is Controls
    var activeView: Int = 1
    
    /// Current state of the controls visible (back button, etc)
    var controlsVisible = false {
        didSet {
            if controlsVisible {
                controlsTimer.schedule(after: 3) { [weak self] in
                    self?.setCameraControlsVisible(false)
                }
            }
        }
    }
    
    /// Timer object which is used to auto-hide the controls
    var controlsTimer = InterruptableTimer()
    
    /// Gradient layer used under the controls (back button, etc) to make them stand out
    var controlsGradientLayer: CAGradientLayer?
    
    /// Returns an array of all the current chat messages to show, taking into account the chat filter control
    var chatMessages: [ChatMessage] {
        let allMessages = Socket.shared.chatMessages
        return allMessages
//        switch chatFilterControl.selectedSegmentIndex {
//        case 1: return allMessages.filter { $0.robotName.lowercased() == robot.name.lowercased() }
//        default: return allMessages
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loading view is at back of hierarchy on storyboard to make it easier to modify the design
        // Bring it to the front so it's visible to users
        view.bringSubview(toFront: loadingViewContainer)
        view.bringSubview(toFront: backButton)
        
        robot.download { [weak self] success in
            guard success else {
                self?.loadingMessageLabel.text = "Error Loading Robot :("
                return
            }
            
            self?.titleLabel.text = self?.robot.name
            self?.subscriberCountLabel.text = String(describing: self?.robot.subscribers?.count ?? 0)
            
            if self?.robot.subscribers?.first(where: { $0.username.lowercased() == Config.shared?.user?.username.lowercased() }) != nil {
                self?.subscribeButton.setTitle("unsubscribe", for: .normal)
            }
            
            if let owner = self?.robot.owner {
                self?.ownerLabel.text = "Owner: \(owner)"
                self?.titleVerticalConstraint.constant = -6
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self?.loadingViewContainer.alpha = 0
            }, completion: { success in
                self?.setCameraControlsVisible(true, animated: false)
            })
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        chatTableView.re.delegate = self
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCamera))
        cameraOverlayView.addGestureRecognizer(tapGesture)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = cameraOverlayView.bounds
        let black = UIColor.black.withAlphaComponent(0.8).cgColor
        gradientLayer.colors = [black, UIColor.clear.cgColor, UIColor.clear.cgColor, black]
        gradientLayer.locations = [NSNumber(value: 0), NSNumber(value: 0.35), NSNumber(value: 0.8) ,NSNumber(value: 1)]
        cameraOverlayView.layer.insertSublayer(gradientLayer, at: 0)
        controlsGradientLayer = gradientLayer
        
        subscriberCountContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        subscriberCountContainerView.layer.borderWidth = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chatTextField.attributedPlaceholder = NSAttributedString(string: "Type your text here...", attributes: [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)
        ])
        
        if let cameraURL = URL(string: "https://runmyrobot.com/fullview/\(robot.id)") {
            // Turn off interaction as there is nothing to interact with, and this prevents scrolling/bouncing and zooming.
            cameraWebView.isUserInteractionEnabled = false
            
            // Delegate is set to fix the video feed from being partly cut off
            cameraWebView.delegate = self
            
            let request = URLRequest(url: cameraURL)
            cameraWebView.loadRequest(request)
        }
        
        Socket.shared.chatCallback = { [weak self] message in
            self?.chatUpdated(message: message)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        controlsGradientLayer?.frame = cameraOverlayView.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        Socket.shared.chatCallback = nil
    }
    
    func setCameraControlsVisible(_ visible: Bool, animated: Bool = true) {
        guard visible != controlsVisible else { return }
        controlsVisible = visible
        
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            let alpha: CGFloat = self.controlsVisible ? 1 : 0
            for view in self.cameraOverlayView.subviews {
                view.alpha = alpha
            }
            
            self.backButton.alpha = alpha
            self.controlsGradientLayer?.opacity = Float(alpha)
        }
    }
    
    func command(from tag: Int) -> RobotCommand? {
        switch tag {
        case 1: return .forward
        case 2: return .backward
        case 3: return .left
        case 4: return .right
        default: return nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func chatUpdated(message: ChatMessage) {
        chatTableView.beginUpdates()
        let count = chatMessages.count
        
        if count == 100 {
            chatTableView.re.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        chatTableView.re.insertRows(at: [IndexPath(row: count - 1, section: 0)], with: .automatic)
        chatTableView.endUpdates()
    }
    
    // MARK: - Notifications
    
    func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animation = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIViewAnimationOptions(rawValue: animation)
        
        if endFrame.origin.y >= UIScreen.main.bounds.size.height {
            viewSwapperBottomConstraint.constant = 0
        } else {
            viewSwapperBottomConstraint.constant = endFrame.size.height
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
