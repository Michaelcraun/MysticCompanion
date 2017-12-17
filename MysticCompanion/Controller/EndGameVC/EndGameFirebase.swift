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
        var finishedPlayerCount = 0
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
        guard let playersArray = GameHandler.instance.game["players"] as? [Dictionary<String,AnyObject>] else { return }
        players = playersArray
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    for player in playersArray {
                        guard let finished = player["finished"] as? Bool else { return }
                        if finished {
                            finishedPlayerCount += 1
                        }
                    }
                    self.players = playersArray
                    if finishedPlayerCount == self.players.count {
                        //TODO: Finish game
                        print("game finalized")
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
                            guard let fbPlayerVP = player["victoryPoints"] as? Int else { return }
                            let newCurrentVP = fbPlayerVP + deckVP
                            newPlayer["victoryPoints"] = newCurrentVP as AnyObject
                            newPlayer["finished"] = true as AnyObject
                            newPlayersArray.append(newPlayer)
                        } else {
                            newPlayersArray.append(player)
                        }
                    }
                    self.players = newPlayersArray
                    GameHandler.instance.updateFirebaseDBGame(key: gameKey, gameData: ["players" : self.players])
                }
            }
        })
    }
}
