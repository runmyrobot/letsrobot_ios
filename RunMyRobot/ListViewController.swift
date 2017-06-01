//
//  ListViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James (Apprentice Software Developer) on 01/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    var robots: [Robot]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Config.download { config in
            let robots = Array(config.robots.values)
            let online = robots.filter { $0.live }
            let offline = robots.filter { !$0.live }
            
            self.robots = online + offline
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRobot", let destination = segue.destination as? StreamViewController {
            destination.robot = sender as? Robot
        }
    }
    
}

extension ListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return robots?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RobotCell", for: indexPath) as! RobotCollectionViewCell
        
        if let robot = robots?[indexPath.item] {
            cell.setRobot(Config.shared?.robots[robot.id] ?? robot)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        performSegue(withIdentifier: "ShowRobot", sender: robots?[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 2
        let usableWidth = collectionView.bounds.width - (24 * 2) // 24 padding on left and right
        let interitemPadding = (columns - 1) * 16
        return CGSize(width: (usableWidth - interitemPadding) / columns, height: 175)
    }
    
}
