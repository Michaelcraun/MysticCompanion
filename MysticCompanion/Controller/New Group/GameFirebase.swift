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
                    guard let gameDict = game.value as? Dictionary<String,AnyObject> else { return }
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    guard let currentPlayer = game.childSnapshot(forPath: "currentPlayer").value as? String else { return }
                    guard let gameEnded = game.childSnapshot(forPath: "gameEnded").value as? Bool else { return }
                    
                    var victoryTaken = 0
                    if playersArray.count <= 1 {
                        self.showAlert(withTitle: "Game Ended", andMessage: "There are not enough players to continue the game. Tap OK to continue.", andNotificationType: .endOfGame)
                    } else {
                        for player in playersArray {
                            guard let playerVictory = player["victoryPoints"] as? Int else { return }
                            victoryTaken += playerVictory
                        }
                    }
                    
                    if gameEnded {
                        self.showAlert(withTitle: "Game Ended", andMessage: "Game has been ended prematurely. Tap OK to continue.", andNotificationType: .endOfGame)
                    }
                    
                    GameHandler.instance.game = gameDict
                    self.players = playersArray
                    self.currentPlayer = currentPlayer
                    self.victoryTaken = victoryTaken
                }
            }
        })
    }
    
    func passTurn(withUserData userData: Dictionary<String,AnyObject>) {
        var newPlayersArray = [Dictionary<String,AnyObject>]()
        var playerToAppend = [String : AnyObject]()
        var newCurrentPlayer = [String : AnyObject]()
        
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
        GameHandler.instance.REF_GAME.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    guard let currentPlayerUsername = game.childSnapshot(forPath: "currentPlayer").value as? String else { return }
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    
                    for player in playersArray {
                        guard let playerUsername = player["username"] as? String else { return }
                        if playerUsername == currentPlayerUsername {
                            playerToAppend = userData
                        } else {
                            newPlayersArray.append(player)
                        }
                    }
                    
                    newPlayersArray.append(playerToAppend)
                    newCurrentPlayer = newPlayersArray[0]
                    guard let newCurrentPlayerUsername = newCurrentPlayer["username"] as? String else { return }
                    GameHandler.instance.updateFirebaseDBGame(key: game.key, gameData: ["currentPlayer" : newCurrentPlayerUsername,
                                                                                        "players" : newPlayersArray])
                    
                    //TODO: Store user statistics on Firebase
                }
            }
        })
    }
}
