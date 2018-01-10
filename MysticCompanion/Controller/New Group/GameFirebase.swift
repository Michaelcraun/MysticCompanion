//
//  GameFirebase.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/10/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

extension GameVC {
    func setupGameAndObserve() {
        GameHandler.instance.REF_GAME.removeAllObservers()
        if let players = GameHandler.instance.game["players"] as? [Dictionary<String,AnyObject>] { self.players = players }
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
        guard let winCondition = GameHandler.instance.game["winCondition"] as? String else { return }
        switch winCondition {
        case "standard":
            vpGoal = 13 + (self.players.count * 5)
            GameHandler.instance.game["vpGoal"] = vpGoal as AnyObject
            GameHandler.instance.updateFirebaseDBGame(key: gameKey, gameData: GameHandler.instance.game)
        case "custom":
            guard let vpGoal = GameHandler.instance.game["vpGoal"] as? Int else { return }
            self.vpGoal = vpGoal
        default: break
        }
        
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    guard let gameDict = game.value as? Dictionary<String,AnyObject> else { return }
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    guard let currentPlayer = game.childSnapshot(forPath: "currentPlayer").value as? String else { return }
                    guard let vpGoal = game.childSnapshot(forPath: "vpGoal").value as? Int else { return }
                    
                    var victoryTaken = 0
                    if playersArray.count <= 1 {
                        self.performSegue(withIdentifier: "showEndGame", sender: nil)
                    } else {
                        for player in playersArray {
                            guard let playerVictory = player["victoryPoints"] as? Int else { return }
                            victoryTaken += playerVictory
                        }
                    }
                    
                    if game.hasChild("gameEnded") {
                        self.performSegue(withIdentifier: "showEndGame", sender: nil)
                    }
                    
                    GameHandler.instance.game = gameDict
                    self.players = playersArray
                    self.currentPlayer = currentPlayer
                    self.victoryTaken = victoryTaken
                    self.vpGoal = vpGoal
                    
                    if self.victoryTaken >= self.vpGoal {
                        self.isEndOfGameTurn = true
                    }
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
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    
                    for player in playersArray {
                        guard let playerUsername = player["username"] as? String else { return }
                        if playerUsername == Player.instance.username {
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
                }
            }
        })
    }
    
    func updateFBUserStatistics(withMana mana: Int, andVictory victory: Int) {
        var userData = Dictionary<String,AnyObject>()
        
        GameHandler.instance.REF_USER.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == FIRAuth.auth()?.currentUser?.uid {
                    if let firebaseUser = user.value as? Dictionary<String,AnyObject> { userData = firebaseUser }
                    guard let mostManaGainedInOneTurn = userData["mostManaGainedInOneTurn"] as? Int else { return }
                    guard let mostVPGainedInOneTurn = userData["mostVPGainedInOneTurn"] as? Int else { return }
                    if mana > mostManaGainedInOneTurn { userData["mostManaGainedInOneTurn"] = mana as AnyObject }
                    if victory > mostVPGainedInOneTurn { userData["mostVPGainedInOneTurn"] = victory as AnyObject }
                    
                    GameHandler.instance.createFirebaseDBUser(uid: user.key, userData: userData)
                }
            }
        })
    }
}
