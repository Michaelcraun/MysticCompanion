//
//  HomeFunctions.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import Firebase

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
    
    func joinGamePressed() {
        self.userIsHostingGame = false
        let userLoaction = self.locationManager.location
        self.layoutGameLobby()
        self.nearbyGames = []
        self.observeGames(withUserLocation: userLoaction!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGame" {
            if let destination = segue.destination as? GameVC {
                destination.game = selectedGame!
                destination.username = username!
            }
        }
    }
}
