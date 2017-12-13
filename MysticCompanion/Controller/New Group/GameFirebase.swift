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
                                        self.players = newPlayersArray
                                        GameHandler.instance.REF_GAME.child(game.key).updateChildValues(["players" : self.players])
                                        self.passTurn()
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
            case "standard": vpGoal = 13 + (self.players.count * 5)
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
                                var victoryTaken = 0
                                //TODO: I think this is the cause of the double call of victoryTaken...
                                for player in playersArray {
                                    if let playerVictory = player["victoryPoints"] as? Int {
                                        victoryTaken += playerVictory
                                    }
                                }
                                self.victoryTaken = victoryTaken
                                self.players = playersArray
                            }
                            
                            if let currentPlayer = game.childSnapshot(forPath: "currentPlayer").value as? String {
                                self.currentPlayer = currentPlayer
                            }
                        }
                    }
                }
            })
        }
    }
    
    func passTurn() {
        let currentPlayerDict: Dictionary<String,AnyObject> = self.players[0]
        var playerToAppend: Dictionary<String,AnyObject>? = nil
        var newCurrentPlayer: Dictionary<String,AnyObject>? = nil
        
        if let gameKey = game["game"] as? String {
            GameHandler.instance.REF_GAME.observeSingleEvent(of: .value, with: { (snapshot) in
                if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    if let currentPlayerUsername = currentPlayerDict["username"] as? String {
                        for game in gameSnapshot {
                            if game.key == gameKey {
                                if let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] {
                                    var newPlayersArray = [Dictionary<String,AnyObject>]()
                                    for player in playersArray {
                                        if let playerUsername = player["username"] as? String {
                                            if playerUsername == currentPlayerUsername {
                                                playerToAppend = player
                                            } else {
                                                newPlayersArray.append(player)
                                            }
                                        }
                                    }
                                    newPlayersArray.append(playerToAppend!)
                                    self.players = newPlayersArray
                                    newCurrentPlayer = self.players[0]
                                    if let newCurrentPlayerUsername = newCurrentPlayer!["username"] as? String {
                                        GameHandler.instance.updateFirebaseDBGame(key: game.key, gameData: ["currentPlayer" : newCurrentPlayerUsername,
                                                                                                            "players" : newPlayersArray])
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
}
