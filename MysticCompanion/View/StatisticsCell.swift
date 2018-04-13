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
            
            let viewElements = [descriptionLabel, valueLabel]
            viewElements.forEach({ (element) in view.addSubview(element) })
            
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
            descriptionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
            descriptionLabel.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor, constant: -5).isActive = true
            
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            valueLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
            valueLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
            valueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
            valueLabel.leadingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 5).isActive = true
            
            return view
        }()
        
        self.addSubview(cellView)
        cellView.translatesAutoresizingMaskIntoConstraints = false
        cellView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        cellView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        cellView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
}
