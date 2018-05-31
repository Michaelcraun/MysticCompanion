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
    
    /// Configures the cell for a specific player
    /// - parameter player: A Dictionary value that contains the speicified player's data
    func layoutCell(forPlayer player: [String : AnyObject]) {
        clearCell()
        
        guard let deck = player["deck"] as? String else { return }
        guard let username = player["username"] as? String else { return }
        guard let playerVP = player["victoryPoints"] as? Int else { return }
        guard let playerBoxVP = player["boxVictory"] as? Int else { return }
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
        deckIcon.backgroundColor = deckType?.color
        deckIcon.anchorTo(self,
                          top: self.topAnchor,
                          bottom: self.bottomAnchor,
                          leading: self.leadingAnchor,
                          padding: .init(top: 5, left: 5, bottom: 5, right: 0),
                          size: .init(width: 17.5, height: 17.5))
        
        let vpLabel = UILabel()
        vpLabel.font = UIFont(name: fontFamily, size: 15)
        vpLabel.text = "\(playerVP + playerBoxVP)"
        vpLabel.numberOfLines = 1
        vpLabel.sizeToFit()
        vpLabel.anchorTo(self,
                         top: self.topAnchor,
                         bottom: self.bottomAnchor,
                         trailing: self.trailingAnchor,
                         padding: .init(top: 5, left: 0, bottom: 5, right: 5))
        
        let usernameLabel = UILabel()
        usernameLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 15)
        usernameLabel.text = username
        usernameLabel.numberOfLines = 1
        usernameLabel.anchorTo(self,
                               top: self.topAnchor,
                               bottom: self.bottomAnchor,
                               leading: deckIcon.trailingAnchor,
                               trailing: vpLabel.leadingAnchor,
                               padding: .init(top: 5, left: 5, bottom: 5, right: 5))
    }
}
