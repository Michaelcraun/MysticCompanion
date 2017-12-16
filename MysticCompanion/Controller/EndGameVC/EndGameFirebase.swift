//
//  EndGameFirebase.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/13/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import Firebase

extension EndGameVC {
    func setupGameAndObserve() {
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
//        guard let gameKey = game["game"] as? String else { return }
        guard let playersArray = GameHandler.instance.game["players"] as? [Dictionary<String,AnyObject>] else { return }
        players = playersArray
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    self.players = playersArray
                }
            }
        })
    }
}
