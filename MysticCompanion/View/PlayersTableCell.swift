//
//  PlayersTableCell.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/10/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class PlayersTableCell: UITableViewCell {
//    override func awakeFromNib() {
//        self.backgroundColor = .clear
//        super.awakeFromNib()
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = .clear
    }
    
    func layoutCell(forPlayer player: Dictionary<String,AnyObject>) {
        clearCell()
        
        guard let deck = player["deck"] as? String else { return }
        guard let username = player["username"] as? String else { return }
        guard let playerVP = player["victoryPoints"] as? Int else { return }
        var deckType: DeckType? {
            switch deck {
            case "beastbrothers": return .beastbrothers
            case "dawnseekers": return .dawnseekers
            case "lifewardens": return .lifewardens
            case "waveguards": return .waveguards
            default: return nil
            }
        }
        
        let deckIcon = CircleView()
        deckIcon.addBorder()
        deckIcon.backgroundColor = deckType?.color
        deckIcon.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        self.addSubview(deckIcon)
        self.addSubview(vpLabel)
        self.addSubview(usernameLabel)
        
        //TODO: Why is the deckIcon not showing up!?
        deckIcon.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        deckIcon.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        deckIcon.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        deckIcon.widthAnchor.constraint(equalToConstant: deckIcon.frame.height).isActive = true
        
        vpLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        vpLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
//        vpLabel.widthAnchor.constraint(equalToConstant: vpLabel.frame.width).isActive = true
        
        usernameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: deckIcon.rightAnchor, constant: 5).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: vpLabel.leftAnchor, constant: -5).isActive = true
    }
}
