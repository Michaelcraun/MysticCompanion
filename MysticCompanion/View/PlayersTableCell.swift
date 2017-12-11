//
//  PlayersTableCell.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/10/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class PlayersTableCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
    }
    
    func clearCell() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func layoutCell(forPlayer player: Dictionary<String,AnyObject>) {
        clearCell()
        
        let username = player["username"] as! String
        let playerVP = player["victoryPoints"] as! Int
        
        let usernameLabel = UILabel()
        usernameLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 15)
        usernameLabel.text = username
        usernameLabel.numberOfLines = 1
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let vpLabel = UILabel()
        vpLabel.font = UIFont(name: fontFamily, size: 15)
        vpLabel.text = "\(playerVP)"
        vpLabel.numberOfLines = 1
        vpLabel.sizeToFit()
        vpLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(vpLabel)
        self.addSubview(usernameLabel)
        
        vpLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        vpLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        vpLabel.widthAnchor.constraint(equalToConstant: vpLabel.frame.width).isActive = true
        
        usernameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: vpLabel.leftAnchor, constant: -5).isActive = true
    }
}
