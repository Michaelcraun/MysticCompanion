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
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
        GameHandler.instance.REF_GAME.observeSingleEvent(of: .value, with: { (snapshot) in
            if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for game in gameSnapshot {
                    if game.key == gameKey {
                        var newPlayersArray = [Dictionary<String,AnyObject>]()
                        guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                        for player in playersArray {
                            guard let playerUsername = player["username"] as? String else { return }
                            if playerUsername != Player.instance.username {
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
        })
    }
    
    func setupGameAndObserve() {
        if let players = GameHandler.instance.game["players"] as? [Dictionary<String,AnyObject>] { self.players = players }
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
        guard let winCondition = GameHandler.instance.game["winCondition"] as? String else { return }
        switch winCondition {
        case "standard": vpGoal = 13 + (self.players.count * 5)
        default:
            guard let vpGoal = GameHandler.instance.game["vpGoal"] as? Int else { return }
            self.vpGoal = vpGoal
        }
        
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    if let gameDict = game.value as? Dictionary<String,AnyObject> {
                        GameHandler.instance.game = gameDict
                    }
                    
                    //TODO: Handle when players exit the game
                    
                    if let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] {
                        var victoryTaken = 0
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
        })
    }
    
    func passTurn() {
        let currentPlayerDict: Dictionary<String,AnyObject> = self.players[0]
        var playerToAppend: Dictionary<String,AnyObject>? = nil
        var newCurrentPlayer: Dictionary<String,AnyObject>? = nil
        
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
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
