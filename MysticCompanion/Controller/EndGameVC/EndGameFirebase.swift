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
        var gameFinalized = false
        var winningVP = 0
        var winningUsername = ""
        
        players = playersArray
        
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    var finishedPlayerCount = 0
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    
                    for player in playersArray {
                        guard let finished = player["finished"] as? Bool else { return }
                        if finished { finishedPlayerCount += 1 }
                        print("GAME OVER: \(self.players.count)")
                        print("GAME OVER: \(finishedPlayerCount)")
                    }
                    
                    if finishedPlayerCount == self.players.count {
                        gameFinalized = true
                        self.players = playersArray
                        self.playersTable.reloadData()
                        
                        for player in playersArray {
                            guard let playerVictoryPoints = player["totalVictoryPoints"] as? Int else { return }
                            if playerVictoryPoints > winningVP {
                                guard let playerUsername = player["username"] as? String else { return }
                                
                                winningVP = playerVictoryPoints
                                winningUsername = playerUsername
                                print("GAME OVER: \(winningUsername)")
                            }
                        }
                        //TODO: Animate cell with username that matches winningUsername
                    }
                    
                    if gameFinalized && game.key == FIRAuth.auth()?.currentUser?.uid {
                        GameHandler.instance.createFirebaseDBData(forGame: game.key, withPlayers: playersArray, andWinner: winningUsername)
                        print("GAME OVER: \(game.key)")
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
                        guard let fbPlayerUsername = player["username"] as? String else { return }
                        if fbPlayerUsername == Player.instance.username {
                            var newPlayer = player
                            guard let firebasePlayerVP = player["victoryPoints"] as? Int else { return }
                            guard let firebasePlayerBoxVP = player["boxVictory"] as? Int else { return }
                            let newCurrentVP = firebasePlayerVP + firebasePlayerBoxVP + deckVP
                            newPlayer["totalVictoryPoints"] = newCurrentVP as AnyObject
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
