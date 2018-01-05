//
//  File.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/29/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

extension UITableView {
    func animate(_ cell: UITableViewCell, shouldBeVisible: Bool, withDelay delay: TimeInterval) {
        UIView.animate(withDuration: 0.5, delay: delay, options: [], animations: {
            if shouldBeVisible {
                cell.alpha = 1
            } else {
                cell.alpha = 0
            }
        }, completion: { (finished) in
            if finished {
                if !shouldBeVisible {
                    self.animate(cell, shouldBeVisible: true, withDelay: delay)
                }
            }
        })
    }
}

extension UITableViewCell {
    func clearCell() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
}
