//
//  HomeFunctions.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

extension HomeVC {
    func setPlayerIcon(withDeck deck: DeckType) {
        UIView.animate(withDuration: 0.5, animations: {
            self.playerIcon.alpha = 0
        }) { (success) in
            self.playerIcon.backgroundColor = deck.color
            self.playerIcon.addImage(deck.image)
            UIView.animate(withDuration: 0.5, animations: {
                self.playerIcon.alpha = 1
            }, completion: nil)
        }
    }
}
