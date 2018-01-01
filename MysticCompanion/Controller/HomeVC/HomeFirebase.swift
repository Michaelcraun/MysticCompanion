//
//  HomeFirebase.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/27/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import MapKit
import Firebase

extension HomeVC {
    func checkUsername(forKey key: String?) {
        if key != nil {
            GameHandler.instance.REF_USER.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
                for user in userSnapshot {
                    if user.key == key {
                        guard let username = user.childSnapshot(forPath: "username").value as? String else { return }
                        Player.instance.username = username
                        self.playerName.text = username
                    }
                }
            })
        } else {
            playerName.text = generateID()
        }
    }
    
    func generateID() -> String {
        var userID = "user"
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        
        for _ in 0..<20 {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            userID += String(newCharacter)
        }
        return userID
    }
    
    func observeGames(withUserLocation location: CLLocation) {
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            var localGames = [Dictionary<String,AnyObject>]()
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                guard let gameStarted = game.childSnapshot(forPath: "gameStarted").value as? Bool else { return }
                if !gameStarted {
                    if game.hasChild("coordinate") {
                        let gameLocationArray = game.childSnapshot(forPath: "coordinate").value as! NSArray
                        let latitude = gameLocationArray[0] as! CLLocationDegrees
                        let longitude = gameLocationArray[1] as! CLLocationDegrees
                        let gameLocation = CLLocation(latitude: latitude, longitude: longitude)
                        let distance = location.distance(from: gameLocation)
                        if distance <= 5 {
                            guard let gameDict = game.value as? Dictionary<String,AnyObject> else { return }
                            localGames.append(gameDict)
                        }
                    }
                }
            }
            self.nearbyGames = localGames
        })
    }
    
    func observeGamesForNewUsers() {
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for game in gameSnapshot {
                    if game.key == self.currentUserID {
                        if let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] {
                            var newPlayers = [Dictionary<String,AnyObject>]()
                            for player in playersArray {
                                newPlayers.append(player)
                            }
                            self.players = newPlayers
                        }
                    }
                }
            }
        })
    }
    
    func observeGamesForStart(forGame selectedGame: Dictionary<String,AnyObject>) {
        if let selectedGameKey = selectedGame["game"] as? String {
            GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
                if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for game in gameSnapshot {
                        if game.key == selectedGameKey {
                            if let gameStarted = game.childSnapshot(forPath: "gameStarted").value as? Bool {
                                if gameStarted {
                                    if let gameDict = game.value as? Dictionary<String,AnyObject> {
//                                        self.selectedGame = gameDict
                                        GameHandler.instance.game = gameDict
                                    }
                                    self.performSegue(withIdentifier: "startGame", sender: nil)
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func updateGame(forGame selectedGame: Dictionary<String,AnyObject>, withUserData userData: Dictionary<String,AnyObject>) {
        var isInGame = false
        var deckTaken = false
        let gameKey = selectedGame["game"] as! String
        guard let userUsername = userData["username"] as? String else { return }
        guard let userDeck = userData["deck"] as? String else { return }
        
        GameHandler.instance.REF_GAME.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    self.players = playersArray
                    if playersArray.count <= 4 {
                        for player in playersArray {
                            guard let playerUsername = player["username"] as? String else { return }
                            if playerUsername == userUsername {
                                isInGame = true
                                break
                            }
                            
                            guard let playerDeck = player["deck"] as? String else { return }
                            if playerDeck == userDeck {
                                deckTaken = true
                                break
                            }
                        }
                        
                        //TODO: Check if user is in game AND their deck is taken and switch deck out if deck isn't taken?
                        if isInGame {
                            self.showAlert(withTitle: "Error:", andMessage: "You're already in that game!", andNotificationType: .error)
                        } else if deckTaken {
                            self.showAlert(withTitle: "Error:", andMessage: "That deck is already taken! Please choose a different one.", andNotificationType: .error)
                        } else {
                            self.players.append(userData)
                        }
                        
                        var gameToUpdate = selectedGame
                        gameToUpdate["players"] = self.players as AnyObject
                        GameHandler.instance.updateFirebaseDBGame(key: game.key, gameData: gameToUpdate)
                    } else {
                        print("game is full")
                        //TODO: Test gameIsFull error
                        self.showAlert(withTitle: "Error:", andMessage: "That game is full. Please select a different game.", andNotificationType: .error)
                    }
                }
            }
        })
    }
    
    func removeUserFromAllGames() {
        GameHandler.instance.REF_GAME.observeSingleEvent(of: .value, with: { (snapshot) in
            if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for game in gameSnapshot {
                    if let playersArray = game.childSnapshot(forPath: "players").value as? NSArray {
                        var newPlayersArray = [String]()
                        for player in playersArray {
                            if let playerUsername = player as? String {
                                if playerUsername != Player.instance.username {
                                    newPlayersArray.append(playerUsername)
                                }
                            }
                        }
                        guard let coordinate = game.childSnapshot(forPath: "coordinate").value as? [CLLocationDegrees] else { return }
                        guard let gameID = game.childSnapshot(forPath: "game").value as? String else { return }
                        guard let fbUsername = game.childSnapshot(forPath: "username").value as? String else { return }
                        guard let winCondition = game.childSnapshot(forPath: "winCondition").value as? String else { return }
                        let gameData: Dictionary<String,Any> = ["coordinate" : coordinate,
                                                                "game" : gameID,
                                                                "username" : fbUsername,
                                                                "winCondition" : winCondition,
                                                                "players" : newPlayersArray]
                        GameHandler.instance.updateFirebaseDBGame(key: game.key, gameData: gameData)
                    }
                }
            }
        })
    }
    
    func hostGameAndObserve(withWinCondition condition: String, andVPGoal goal: Int) {
        let userLocation = self.locationManager.location
        winCondition = condition
        self.players = []
        self.players.append(["username" : Player.instance.username as AnyObject,
                             "deck" : Player.instance.deck?.rawValue as AnyObject,
                             "finished" : false as AnyObject,
                             "victoryPoints" : 0 as AnyObject,
                             "userHasQuitGame" : false as AnyObject,
                             "boxVictory" : 0 as AnyObject])
        let gameData: Dictionary<String,Any> = ["game" : self.currentUserID!,
                                                "winCondition" : condition,
                                                "vpGoal" : goal,
                                                "coordinate" : [userLocation?.coordinate.latitude,
                                                                userLocation?.coordinate.longitude],
                                                "username" : Player.instance.username,
                                                "players" : self.players,
                                                "gameStarted" : false,
                                                "currentPlayer" : Player.instance.username]
        GameHandler.instance.updateFirebaseDBGame(key: self.currentUserID!, gameData: gameData)
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for game in gameSnapshot {
                    if game.key == self.currentUserID! {
                        if let gameDict = game.value as? Dictionary<String,AnyObject> {
//                            self.selectedGame = gameDict
                            GameHandler.instance.game = gameDict
                            guard let playersArray = GameHandler.instance.game["players"] as? [Dictionary<String,AnyObject>] else { return }
                            self.players = playersArray
                        }
                    }
                }
            }
        })
        self.layoutGameLobby()
        self.observeGamesForNewUsers()
    }
}
