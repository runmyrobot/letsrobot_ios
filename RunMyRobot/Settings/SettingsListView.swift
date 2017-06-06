//
//  SettingsListView.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 06/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit
import SnapKit

protocol SettingsListViewDelegate: class {
    
}

class SettingsListView: UIView {
    
    // Public
    weak var delegate: SettingsListViewDelegate?
    
    // Private
    private var tableView: UITableView!
    fileprivate var provider: SettingsListViewProvider!
    
    // Initalisers
    
    convenience init?(provider: SettingsListViewProvider?) {
        guard provider != nil else { return nil }
        self.init(frame: .zero)
        self.provider = provider
//        tableView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // Setup
    func setup() {
        setupTableView()
        registerCells()
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero)
        addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
        tableView.dataSource = self
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "SettingsListSwitchCell", bundle: nil), forCellReuseIdentifier: "Switch")
        tableView.register(UINib(nibName: "SettingsListRobotPickerCell", bundle: nil), forCellReuseIdentifier: "RobotPicker")
    }
}

extension SettingsListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return provider.cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = provider.cellInfo(for: indexPath.item)
        guard let type = cellInfo["type"] as? String else { fatalError() }
        
        switch type {
        case "robotpicker":
            return tableView.dequeueReusableCell(withIdentifier: "RobotPicker", for: indexPath)
        case "toggle":
            let cell = tableView.dequeueReusableCell(withIdentifier: "Switch", for: indexPath) as! SettingsListSwitchCell
            
            if let title = cellInfo["title"] as? String, let subtitle = cellInfo["subtitle"] as? String {
                cell.setText(title, subtitle)
            }
            
            return cell
        default: fatalError()
        }
        
        
//        if indexPath.item == 0 {
//            return tableView.dequeueReusableCell(withIdentifier: "RobotPicker", for: indexPath)
//        }
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Switch", for: indexPath) as! SettingsListSwitchCell
//        let entry = fields[indexPath.item]
//        cell.setText(entry.0, entry.1)
//        return cell
    }
    
}
