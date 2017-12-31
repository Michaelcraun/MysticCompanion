//
//  File.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/29/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func clearCell() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
}
