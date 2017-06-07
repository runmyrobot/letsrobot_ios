//
//  StreamViewController+CustomControls.swift
//  RunMyRobot
//
//  Created by Sherlock, James on 04/06/2017.
//  Copyright © 2017 Sherlouk. All rights reserved.
//

import UIKit

extension StreamViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return robot.panels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let panel = robot.panels?[section] {
            return panel.buttons.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleButton", for: indexPath) as? CustomButtonCollectionViewCell else {
            fatalError()
        }
        
        if let panel = robot.panels?[indexPath.section] {
            let button = panel.buttons[indexPath.item]
            cell.titleButton.setTitle(button.label.uppercased(), for: .normal)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns = min(CGFloat(robot.panels?[indexPath.section].buttons.count ?? 1), 4)
        let usableWidth = collectionView.bounds.width - (16 * 2) // 24 padding on left and right
        let interitemPadding = (columns - 1) * 8
        return CGSize(width: (usableWidth - interitemPadding) / columns, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionTitle", for: indexPath) as? ListTitleCollectionReusableView else {
            fatalError()
        }
        view.titleLabel.text = robot.panels?[indexPath.section].title.uppercased() ?? "UNKNOWN SECTION"
        return view
    }
    
}
