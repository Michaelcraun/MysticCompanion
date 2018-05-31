//
//  StatisticsCell.swift
//  MysticCompanion
//
//  Created by Michael Craun on 4/12/18.
//  Copyright © 2018 Craunic Productions. All rights reserved.
//

import UIKit

class StatisticsCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = .clear
    }
    
    /// Configures a cell for a user's specific statistic
    /// - parameter statistic: The specified statistic to be displayed
    /// - parameter value: The user's value associated with the specified statistic
    func layoutCellForStatistic(_ statistic: String, withValue value: AnyObject?) {
        let cellView: UIView = {
            let view = UIView()
            
            let descriptionLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont(name: "\(fontFamily)-Bold", size: 12)
                label.text = statistic
                return label
            }()
            
            let valueLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont(name: fontFamily, size: 12)
                label.sizeToFit()
                label.text = {
                    if statistic == "Win Percentage" {
                        let winPercentageString = String(format: "%.01f", value as! Double)
                        return "\(winPercentageString)%"
                    }
                    
                    return "\(value!)"
                }()
                label.textAlignment = .right
                return label
            }()
            
            valueLabel.anchorTo(view,
                                top: view.topAnchor,
                                bottom: view.bottomAnchor,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 5, left: 5, bottom: 5, right: 5))
            
            descriptionLabel.anchorTo(view,
                                      top: view.topAnchor,
                                      bottom: view.bottomAnchor,
                                      leading: view.leadingAnchor,
                                      trailing: valueLabel.leadingAnchor,
                                      padding: .init(top: 5, left: 5, bottom: 5, right: 5))
            
            return view
        }()
        
        cellView.fillTo(self)
    }
}
