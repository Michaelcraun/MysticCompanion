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
        guard let playersArray = GameHandler.instance.game["players"] as? [Dictionary<String,AnyObject>] else { return }
        var finishedPlayerCount = 0
        var winningVP = 0
        var winningUsername = "" {
            didSet {
                self.winningUsername = winningUsername
            }
        }
        players = playersArray
        
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    guard let hostUsername = game.childSnapshot(forPath: "username").value as? String else { return }
                    
                    for player in playersArray {
                        guard let finished = player["finished"] as? Bool else { return }
                        if finished { finishedPlayerCount += 1 }
                    }
                    
                    if finishedPlayerCount >= self.players.count {
                        self.players = playersArray
                        self.playersTable.reloadData()
                        self.layoutMenuButton(gameState: .gameFinalized)
                        
                        for player in playersArray {
                            guard let playerVictoryPoints = player["victoryPoints"] as? Int else { return }
                            if playerVictoryPoints > winningVP {
                                guard let playerUsername = player["username"] as? String else { return }
                                
                                winningVP = playerVictoryPoints
                                winningUsername = playerUsername
                            }
                        }
                        
                        if hostUsername == Player.instance.username {
                            print("GAME OVER: Creating Data entry and clearing game...")
                            GameHandler.instance.createFirebaseDBData(forGame: game.key, withPlayers: playersArray, andWinner: winningUsername)
                            GameHandler.instance.clearCurrentGamesFromFirebaseDB(forKey: game.key)
                        }
                    }
                }
            }
        })
    }
    
    func updateUser(_ user: String, withDeckVP deckVP: Int) {
        var newPlayersArray = [Dictionary<String,AnyObject>]()
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
        GameHandler.instance.REF_GAME.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    for player in playersArray {
                        guard let firebasePlayerUsername = player["username"] as? String else { return }
                        if firebasePlayerUsername == Player.instance.username {
                            var newPlayer = player
                            guard let firebasePlayerVP = player["victoryPoints"] as? Int else { return }
                            let newCurrentVP = firebasePlayerVP + deckVP
                            newPlayer["victoryPoints"] = newCurrentVP as AnyObject
                            newPlayer["finished"] = true as AnyObject
                            newPlayersArray.append(newPlayer)
                        } else {
                            newPlayersArray.append(player)
                        }
                    }
                    GameHandler.instance.updateFirebaseDBGame(key: gameKey, gameData: ["players" : newPlayersArray])
                }
            }
        })
    }
}
