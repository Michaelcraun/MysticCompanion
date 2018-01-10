//
//  EndGameFirebase.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/13/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

extension EndGameVC {
    func setupGameAndObserve() {
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
        guard let hostUsername = GameHandler.instance.game["username"] as? String else { return }
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
                            guard let playerBoxVP = player["boxVictory"] as? Int else { return }
                            guard let playerUsername = player["username"] as? String else { return }
                            let playerTotalVictory = playerVictoryPoints + playerBoxVP
                            if playerTotalVictory > winningVP {
                                winningVP = playerTotalVictory
                                winnersArray = [playerUsername]
                            } else if playerTotalVictory == winningVP {
                                winnersArray.append(playerUsername)
                            }
                        }
                        
                        guard let gameData = game.value as? Dictionary<String,AnyObject> else { return }
                        GameHandler.instance.game = gameData
                        
                        self.updateFBUserStatistics(withPlayers: playersArray, andWinners: winnersArray)
                        if hostUsername == Player.instance.username {
                            guard let currentUID = FIRAuth.auth()?.currentUser?.uid else { return }
                            guard let playersArray = GameHandler.instance.game["players"] as? [Dictionary<String,AnyObject>] else { return }
                            
                            GameHandler.instance.clearCurrentGamesFromFirebaseDB(forKey: currentUID)
                            GameHandler.instance.createFirebaseDBData(forGame: currentUID, withPlayers: playersArray, andWinners: winnersArray)
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
    
    func updateFBUserStatistics(withPlayers players: [Dictionary<String,AnyObject>], andWinners winners: [String]) {
        var userData = Dictionary<String,AnyObject>()
        var gamesPlayed = 0
        var gamesWon = 0
        var gamesLost = 0
        
        GameHandler.instance.REF_USER.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == FIRAuth.auth()?.currentUser?.uid {
                    if let firebaseUser = user.value as? Dictionary<String,AnyObject> { userData = firebaseUser }
                    if let firebaseGamesPlayed = userData["gamesPlayed"] as? Int { gamesPlayed = firebaseGamesPlayed }
                    if let firebaseGamesWon = userData["gamesWon"] as? Int { gamesWon = firebaseGamesWon }
                    if let firebaseGamesLost = userData["gamesLost"] as? Int { gamesLost = firebaseGamesLost }
                    guard let firebaseMostVPGainedInOneGame = userData["mostVPGainedInOneGame"] as? Int else { return }
                    
                    gamesPlayed += 1
                    for winner in winners {
                        if winner == Player.instance.username {
                            gamesWon += 1
                            break
                        } else {
                            gamesLost += 1
                        }
                    }
                    
                    for player in players {
                        guard let playerUsername = player["username"] as? String else { return }
                        if playerUsername == Player.instance.username {
                            guard let victoryPoints = player["victoryPoints"] as? Int else { return }
                            guard let boxVP = player["boxVictory"] as? Int else { return }
                            let gameTotalVictory = victoryPoints + boxVP
                            
                            if gameTotalVictory > firebaseMostVPGainedInOneGame {
                                userData["mostVPGainedInOneGame"] = gameTotalVictory as AnyObject
                            }
                        }
                    }
                    
                    userData["gamesPlayed"] = gamesPlayed as AnyObject
                    userData["gamesWon"] = gamesWon as AnyObject
                    userData["gamesLost"] = gamesLost as AnyObject
                    
                    GameHandler.instance.createFirebaseDBUser(uid: user.key, userData: userData)
                }
            }
        })
    }
}
