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
    
    func updateFirebaseDBGame(withUserData userData: Dictionary<String,AnyObject>) {
        if let gameKey = game["game"] as? String {
            GameHandler.instance.REF_GAME.observeSingleEvent(of: .value, with: { (snapshot) in
                if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for game in gameSnapshot {
                        if game.key == gameKey {
                            self.players = []
                            if let playerArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] {
                                for player in playerArray {
                                    if let playerUsername = player["username"] as? String {
                                        if playerUsername != self.player.username {
                                            self.players.append(player)
                                        } else {
                                            self.players.append(userData)
                                        }
                                        GameHandler.instance.REF_GAME.child(game.key).updateChildValues(["players" : self.players])
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func setupGameAndObserve() {
        if let players = game["players"] as? [Dictionary<String,AnyObject>] { self.players = players }
        if let gameKey = game["game"] as? String {
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
    }
}
