//
//  GameFirebase.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/10/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import Firebase

extension GameVC {
    func observeCurrentGame(_ game: Dictionary<String,AnyObject>) {
        let gameKey = game["game"] as! String
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for game in gameSnapshot {
                    if game.key == gameKey {
                        if let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] {
                            self.players = playersArray
                        }
                    }
                }
            }
        })
    }
    
    func updateFirebaseDBGame(_ game: Dictionary<String,AnyObject>, withUserData userData: Dictionary<String,AnyObject>) {
        
    }
}
