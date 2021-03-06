//
//  StreamViewController+ChatView.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

extension StreamViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        previousChatCount = chatMessages.count
        return previousChatCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessage", for: indexPath) as? ChatMessageTableViewCell else {
            fatalError()
        }
        
        let count = chatMessages.count - 1 - indexPath.row
        
        if count >= 0 {
            cell.setNewMessage(chatMessages[count])
        }
        
        cell.parentViewController = self
        cell.robot = robot
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
