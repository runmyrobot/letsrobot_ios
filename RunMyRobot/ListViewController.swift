//
//  ListViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 01/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import Popover

class ListViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    var onlineRobots: [Robot]?
    var offlineRobots: [Robot]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 44)))
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        guard let config = Config.shared else { return }
        let robots = Array(config.robots.values)
        self.onlineRobots = robots.filter { $0.live }
        self.offlineRobots = robots.filter { !$0.live }
        
        self.collectionView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRobot", let destination = segue.destination as? StreamViewController {
            destination.robot = sender as? Robot
        }
    }
    
    func robotForIndexPath(_ indexPath: IndexPath) -> Robot? {
        if indexPath.section == 0 {
            return onlineRobots?[indexPath.item]
        }
        
        return offlineRobots?[indexPath.item]
    }
    
    @IBAction func didPressUser() {
        let popover = Popover(options: [
            .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
            .color(UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1))
        ])
        
        let loginView = LoginView.createView()
        loginView.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 50, height: 350)
        
        popover.willShowHandler = {
            loginView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 50, height: 350)
        }
        
        loginView.success = {
            popover.dismiss()
        }
        
        popover.showAsDialog(loginView)
    }
    
    @IBAction func didPressOpenMenu() {
        slideMenuController()?.toggleLeft()
    }
}

extension ListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            // Online
            return onlineRobots?.count ?? 0
        }
        
        // Offline
        return offlineRobots?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RobotCell", for: indexPath) as? RobotCollectionViewCell else {
            fatalError()
        }
        
        if let robot = robotForIndexPath(indexPath) {
            cell.setRobot(Config.shared?.robots[robot.id] ?? robot)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        performSegue(withIdentifier: "ShowRobot", sender: robotForIndexPath(indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 2
        let usableWidth = collectionView.bounds.width - (24 * 2) // 24 padding on left and right
        let interitemPadding = (columns - 1) * 16
        return CGSize(width: (usableWidth - interitemPadding) / columns, height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionTitle", for: indexPath) as? ListTitleCollectionReusableView else {
            fatalError()
        }
        
        view.titleLabel.text = indexPath.section == 0 ? "ONLINE ROBOTS" : "OFFLINE ROBOTS"
        return view
    }
    
}
