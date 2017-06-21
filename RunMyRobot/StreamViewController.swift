//
//  StreamViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 31/05/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import ReverseExtension
import Crashlytics
import PopupDialog

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
    @IBOutlet var chatPageButton: UIButton!
    @IBOutlet var chatFilterLabel: UILabel!
    
    // Controls
    @IBOutlet var controlContainerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var ownerLabel: UILabel!
    
    // Loading View
    @IBOutlet var loadingViewContainer: UIView!
    @IBOutlet var loadingMessageLabel: UILabel!
    
    // Subscribe
    @IBOutlet var subscribeButton: UIButton!
    @IBOutlet var subscriberCountLabel: UILabel!
    @IBOutlet var subscriberCountContainerView: UIView!
    @IBOutlet var subscribeIndicator: UIActivityIndicatorView!
    
    // Constraints
    @IBOutlet var gameIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var chatBoxTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var viewSwapperBottomConstraint: NSLayoutConstraint!
    @IBOutlet var titleVerticalConstraint: NSLayoutConstraint!
    
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
    var controlsGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        
        let black = UIColor.black.withAlphaComponent(0.8).cgColor
        let clear = UIColor.clear.cgColor
        
        gradientLayer.colors = [black, clear, clear, black]
        gradientLayer.locations = [NSNumber(value: 0), NSNumber(value: 0.35), NSNumber(value: 0.8), NSNumber(value: 1)]
        
        return gradientLayer
    }()
    
    /// Stores the amount of chat messages in order to realise if we need to reset the last cell to a new message
    var previousChatCount: Int = 0
    
    /// Returns an array of all the current chat messages to show, taking into account the chat filter control
    var chatMessages: [ChatMessage] {
        let allMessages = Socket.shared.chat.messages
        
        if robot.isGlobalChat == true {
            return allMessages
        }
        
        return allMessages.filter {
            // Allow all non-user chat messages (system message)
            guard let userMessage = $0 as? UserChatMessage else {
                return true
            }
            
            return userMessage.room == robot.owner
        }
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
            self?.subscriberCountLabel.text = String(describing: self?.robot.subscribers.count ?? 0)
            
            self?.robot.updateSubscribers = { [weak self] in
                self?.subscriberCountLabel.text = String(describing: self?.robot.subscribers.count ?? 0)
            }
            
            if let username = User.current?.username, self?.robot.subscribers.contains(username) == true {
                self?.subscribeButton.setTitle("unfollow", for: .normal)
            }
            
            if let owner = self?.robot.owner {
                self?.ownerLabel.text = "Owner: \(owner)"
                self?.titleVerticalConstraint.constant = -6
            }
            
            if let controlsView = self?.controlContainerView, let robot = self?.robot {
                RobotControls.create(for: robot).embed(in: controlsView)
            }
            
            self?.chatFilterLabel.text = self?.robot.isGlobalChat == true ? "Global Chat" : "Room Chat: \(self?.robot.owner ?? "Unknown")"
            
            UIView.animate(withDuration: 0.3, animations: {
                self?.loadingViewContainer.alpha = 0
            }, completion: { _ in
                self?.setCameraControlsVisible(true, animated: false)
            })
            
            Answers.logContentView(withName: "Viewed Robot Stream", contentType: "robot", contentId: self?.robot.id)
            
            if let robot = self?.robot {
                Socket.shared.selectRobot(robot)
            }
        }
        
        // Add notification listeners
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendScreenshot), name: .UIApplicationUserDidTakeScreenshot, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(streamStateChanged(_:)), name: NSNotification.Name("RobotStateChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateActiveUsers), name: NSNotification.Name("UpdateActiveUsers"), object: nil)
        
        // Set the tableView delegate to be self, dataSource is done via storyboard
        chatTableView.re.delegate = self
        
        // Hide the navigation bar, as we have a custom overlay view for this controller
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Add tap gesture for camera overlay view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCamera))
        cameraOverlayView.addGestureRecognizer(tapGesture)
        
        // Add gradient layer to camera overlay view
        controlsGradientLayer.frame = cameraOverlayView.bounds
        cameraOverlayView.layer.insertSublayer(controlsGradientLayer, at: 0)
        
        // Add border to subscriber count container view
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
        
//        if let cameraURL = URL(string: "https://www.runmyrobot.com/") {
            if let cameraURL = URL(string: "\(Networking.baseUrl)/fullview/\(robot.id)") {
            // Turn off interaction as there is nothing to interact with, and this prevents scrolling/bouncing and zooming.
            cameraWebView.isUserInteractionEnabled = false
            
            // Delegate is set to fix the video feed from being partly cut off
            cameraWebView.delegate = self

            let request = URLRequest(url: cameraURL)
            cameraWebView.loadRequest(request)
        }
        
        Socket.shared.chat.chatCallback = { [weak self] message in
            self?.chatUpdated(message: message)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        controlsGradientLayer.frame = cameraOverlayView.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        Socket.shared.chat.chatCallback = nil
        robot.updateSubscribers = nil
        robot.updateControls = nil
        robot.controls = nil
        cameraWebView.stopLoading()
        cameraWebView.delegate = nil
        cameraWebView.removeFromSuperview()
    }
    
    func updateActiveUsers() {
        
    }
    
    func sendScreenshot() {
        let vc = SendScreenshotViewController.create()
        vc.robot = robot
        vc.image = cameraWebView.screengrab
        vc.messageViewController = self
        
        let popup = PopupDialog(viewController: vc, transitionStyle: .zoomIn)
        present(popup, animated: true, completion: nil)
    }
    
    func streamStateChanged(_ notification: NSNotification) {
        guard let robotId = notification.userInfo?["robot_id"] as? String else { return }
        guard robotId == robot.id else { return }
        
        showMessage("\(robot.name) just went \(robot.live ? "online" : "offline")!", type: .info)
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
            self.controlsGradientLayer.opacity = Float(alpha)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func chatUpdated(message: ChatMessage) {
        if let userChatMessage = message as? UserChatMessage {
            if robot.isGlobalChat == false && userChatMessage.room != robot.owner {
                return
            }
        }
        
        chatTableView.beginUpdates()
        
        if previousChatCount == Chat.messageCountCap {
            chatTableView.re.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        let count = chatMessages.count
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
