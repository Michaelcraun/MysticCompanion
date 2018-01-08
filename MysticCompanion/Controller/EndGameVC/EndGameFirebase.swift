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
        var winnersArray = [String]() {
            didSet {
                self.winnersArray = winnersArray
            }
        }
        players = playersArray
        
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    finishedPlayerCount = 0
                    
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
                            guard let playerUsername = player["username"] as? String else { return }
                            if playerVictoryPoints > winningVP {
                                winningVP = playerVictoryPoints
                                winnersArray = [playerUsername]
                            } else if playerVictoryPoints == winningVP {
                                winnersArray.append(playerUsername)
                            }
                        }
                        
                        guard let gameData = game.value as? Dictionary<String,AnyObject> else { return }
                        GameHandler.instance.game = gameData
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
