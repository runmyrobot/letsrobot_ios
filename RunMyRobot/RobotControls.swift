//
//  RobotControls.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 14/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import SnapKit

class RobotControls: UIView {

    @IBOutlet var tableView: UITableView!
    
    var robot: Robot!
    
    var panels: [ButtonPanel]!
    
    class func create(for robot: Robot) -> RobotControls {
        let nib = UINib(nibName: "RobotControls", bundle: nil)
        
        guard let controls = nib.instantiate(withOwner: self, options: nil).first as? RobotControls else {
            fatalError()
        }
        
        controls.robot = robot
        controls.panels = robot.getControlPanels()
        
        robot.controls = controls
        controls.updateControls()
        return controls
    }
    
    func embed(in view: UIView) {
        view.addSubview(self)
        
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        robot.updateControls = { [weak self] in
            Threading.run(on: .main) { [weak self] in
                self?.updateControls()
            }
        }
        
        setupTableView()
    }
    
    func setupTableView() {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "RobotControlGroupTableViewCell", bundle: nil), forCellReuseIdentifier: "ButtonPanelCell")
        tableView.dataSource = self
    }
    
    func flashCommand(_ command: String) {
        guard let cells = tableView.visibleCells as? [RobotControlGroupTableViewCell] else { return }
        
        for cell in cells {
            guard let tagView = cell.tagView(from: command) else { continue }
            tagView.isSelected = true
            
            Threading.run(on: .main, after: 0.1) {
                tagView.isSelected = false
            }
        }
    }
    
    func updateControls() {
        guard let cells = tableView.visibleCells as? [RobotControlGroupTableViewCell] else { return }
        
        for cell in cells {
            for tagView in cell.tagView.tagViews {
                if robot.currentCommand != nil, cell.command(from: tagView) == robot.currentCommand {
                    tagView.borderColor = .white
                    tagView.borderWidth = 2
                } else {
                    tagView.borderColor = tagView.tagBackgroundColor.darker(by: 5)
                    tagView.borderWidth = 1
                }
            }
        }
    }
}

extension RobotControls: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return panels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonPanelCell", for: indexPath) as? RobotControlGroupTableViewCell else {
            fatalError()
        }
        
        cell.robot = robot
        cell.setControls(panel: panels[indexPath.item])
        return cell
    }
}
