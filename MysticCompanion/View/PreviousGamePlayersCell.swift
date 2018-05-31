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
    
    /// Configures the cell for a specific player from a previous game
    /// - parameter player: A Dictionary containing the specified player's data
    /// - parameter winners: An Array of String values that contains the winner(s) of a specified game
    func layoutCell(forPlayer player: [String : AnyObject], withWinners winners: [String]) {
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
        deckView.addImage((deckType?.image)!, withSize: 6)
        deckView.backgroundColor = deckType?.color
        deckView.anchorTo(self,
                          top: self.topAnchor,
                          bottom: self.bottomAnchor,
                          leading: self.leadingAnchor,
                          padding: .init(top: 2, left: 2, bottom: 2, right: 0),
                          size: .init(width: deckView.frame.height, height: 0))
        
        let vpLabel = UILabel()
        vpLabel.font = UIFont(name: fontFamily, size: 15)
        vpLabel.text = "\(victoryPoints)"
        vpLabel.numberOfLines = 1
        vpLabel.sizeToFit()
        vpLabel.anchorTo(self,
                         top: self.topAnchor,
                         trailing: self.trailingAnchor,
                         size: .init(width: vpLabel.frame.width, height: vpLabel.frame.height))
        
        let usernameLabel = UILabel()
        for winner in winners {
            if username == winner {
                usernameLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 15)
                break
            } else {
                usernameLabel.font = UIFont(name: fontFamily, size: 15)
            }
        }
        usernameLabel.text = username
        usernameLabel.numberOfLines = 1
        usernameLabel.anchorTo(self,
                               top: self.topAnchor,
                               leading: deckView.rightAnchor,
                               trailing: vpLabel.leadingAnchor,
                               padding: .init(top: 5, left: 5, bottom: 0, right: 5))
    }
}
