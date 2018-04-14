//
//  File.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/29/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

extension UITableView {
    /// Animates the tableView's alpha to 0, then reloads the tableView's data, and finally animates the tableView's
    /// alpha to 1
    func animate() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { (finished) in
            if finished {
                self.reloadData()
                UIView.animate(withDuration: 0.5, animations: {
                    self.alpha = 1
                })
            }
        }
    }
}

extension UITableViewCell {
    /// Clears the cell of all subviews within the cell
    func clearCell() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        self.updateConstraints()
    }
}
