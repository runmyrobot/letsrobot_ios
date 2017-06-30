//
//  UserListModalViewController.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 23/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

class UserListModalViewController: UIViewController {

    @IBOutlet var listTableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    
    var list = [User]()
    var robot: Robot!
    
    class func create() -> UserListModalViewController {
        let storyboard = UIStoryboard(name: "Modals", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "UserList") as? UserListModalViewController else {
            fatalError()
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cache list in case it changes and causes issues
        list = User.all(for: robot)
        listTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        titleLabel.text = "Room: \(robot.room)"
    }
}

extension UserListModalViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserListTableViewCell else {
            fatalError()
        }
        
        cell.parent = self
        cell.robot = robot
        cell.loadUser(list[indexPath.item])
        return cell
    }
}
