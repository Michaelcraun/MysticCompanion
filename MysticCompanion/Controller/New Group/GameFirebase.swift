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
                            var newPlayersArray = [Dictionary<String,AnyObject>]()
                            if let playerArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] {
                                for player in playerArray {
                                    if let playerUsername = player["username"] as? String {
                                        if playerUsername != self.player.username {
                                            newPlayersArray.append(player)
                                        } else {
                                            newPlayersArray.append(userData)
                                        }
                                        GameHandler.instance.REF_GAME.child(game.key).updateChildValues(["players" : newPlayersArray])
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
        if let winCondtion = game["winCondition"] as? String {
            switch winCondtion {
            case "standard": vpGoal += self.players.count * 5
            default:
                if let vpGoal = game["vpGoal"] as? Int {
                    self.vpGoal = vpGoal
                }
            }
        }
        
        player.username = username
        if let gameKey = game["game"] as? String {
            GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
                if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for game in gameSnapshot {
                        if game.key == gameKey {
                            if let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] {
                                self.players = playersArray
                                var victoryTaken = 0
                                for player in playersArray {
                                    if let playerVictory = player["victoryPoints"] as? Int {
                                        victoryTaken += playerVictory
                                    }
                                }
                                self.victoryTaken = victoryTaken
                            }

                            //TODO: if current player, enable endTurnButton; else, disable endTurnButton
//                            if let currentPlayer = game.childSnapshot(forPath: "currentPlayer").value as? String {
//                                if currentPlayer == self.player.username {
//                                    self.endTurnButton.isUserInteractionEnabled = true
//                                } else {
//                                    self.endTurnButton.isUserInteractionEnabled = false
//                                }
//                            }
                        }
                    }
                }
            })
        }
    }
}
