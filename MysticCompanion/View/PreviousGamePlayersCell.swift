//
//  PreviousGamePlayersTable.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/29/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class PreviousGamePlayersCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = .clear
    }
    
    func layoutCell(forPlayer player: Dictionary<String,AnyObject>, withWinner winner: String) {
        clearCell()
        
        guard let username = player["username"] as? String else { return }
        guard let deck = player["deck"] as? String else { return }
        guard let victoryPoints = player["victoryPoints"] as? Int else { return }
        var deckType: DeckType? {
            switch deck {
            case "beastbrothers": return .beastbrothers
            case "dawnseekers": return .dawnseekers
            case "lifewardens": return .lifewardens
            case "waveguards": return .waveguards
            default: return nil
            }
        }
        
        let deckView = CircleView()
        deckView.addBorder()
        deckView.addImage((deckType?.image)!, withWidthModifier: 6)
        deckView.backgroundColor = deckType?.color
        deckView.translatesAutoresizingMaskIntoConstraints = false
        
        let usernameLabel = UILabel()
        if username == winner {
            usernameLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 15)
        } else {
            usernameLabel.font = UIFont(name: fontFamily, size: 15)
        }
        usernameLabel.text = username
        usernameLabel.numberOfLines = 1
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let vpLabel = UILabel()
        vpLabel.font = UIFont(name: fontFamily, size: 15)
        vpLabel.text = "\(victoryPoints)"
        vpLabel.numberOfLines = 1
        vpLabel.sizeToFit()
        vpLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(vpLabel)
        self.addSubview(deckView)
        self.addSubview(usernameLabel)
        
        vpLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        vpLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        vpLabel.widthAnchor.constraint(equalToConstant: vpLabel.frame.width).isActive = true
        
        deckView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        deckView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2).isActive = true
        deckView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
        deckView.widthAnchor.constraint(equalTo: deckView.heightAnchor).isActive = true
        
        usernameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: deckView.rightAnchor, constant: 5).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: vpLabel.leftAnchor, constant: -5).isActive = true
    }
}
