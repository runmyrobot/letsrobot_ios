//
//  ListViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 01/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    var myRobots: [Robot]?
    var onlineRobots: [Robot]?
    var offlineRobots: [Robot]?
    
    var robotList: [(String, [Robot])] {
        var builder = [(String, [Robot])]()
        
        if let myRobots = myRobots, myRobots.count > 0 {
            builder.append(("MY ROBOTS", myRobots))
        }
        
        if let onlineRobots = onlineRobots, onlineRobots.count > 0 {
            builder.append(("ONLINE ROBOTS", onlineRobots))
        }
        
        if let offlineRobots = offlineRobots, offlineRobots.count > 0 {
            builder.append(("OFFLINE ROBOTS", offlineRobots))
        }
        
        return builder
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 44)))
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        
        updateRobots()
        NotificationCenter.default.addObserver(self, selector: #selector(updateRobots), name: NSNotification.Name("RobotsChanged"), object: nil)
    }
    
    func updateRobots() {
        guard let config = Config.shared else { return }
        let robots = Array(config.robots.values)
        self.myRobots = User.current?.robots
        
        let notMyRobot: ((Robot) -> Bool) = { robot in
            if let owner = robot.owner {
                return owner != User.current?.username
            }
            
            return true
        }
        
        self.onlineRobots = robots.filter { $0.live && notMyRobot($0) }
        self.offlineRobots = robots.filter { !$0.live && notMyRobot($0) }
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
    
    @IBAction func didPressOpenMenu() {
        slideMenuController()?.toggleLeft()
    }
}

extension ListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return robotList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return robotList[section].1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RobotCell", for: indexPath) as? RobotCollectionViewCell else {
            fatalError()
        }
        
        let robot = robotList[indexPath.section].1[indexPath.item]
        cell.setRobot(Config.shared?.robots[robot.id] ?? robot)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let robot = robotList[indexPath.section].1[indexPath.item]
        
        Threading.run(on: .main) {
            self.performSegue(withIdentifier: "ShowRobot", sender: robot)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 2
        let usableWidth = collectionView.bounds.width - (24 * 2) // 24 padding on left and right
        let interitemPadding = (columns - 1) * 16
        return CGSize(width: (usableWidth - interitemPadding) / columns, height: 185)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionTitle", for: indexPath) as? ListTitleCollectionReusableView else {
            fatalError()
        }
        
        view.titleLabel.text = robotList[indexPath.section].0.uppercased()
        return view
    }
    
}
