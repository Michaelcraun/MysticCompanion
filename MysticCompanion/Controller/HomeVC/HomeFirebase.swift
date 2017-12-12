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
                if let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for user in userSnapshot {
                        if user.key == key {
                            if let username = user.childSnapshot(forPath: "username").value as? String {
                                self.username = username
                                self.playerName.text = username
                            }
                        }
                    }
                }
            })
        } else {
            playerName.text = generateID()
        }
    }
    
    func getUsernameFromFB(forKey key: String?) -> String {
        var fbUsername = ""
        if key != nil {
            GameHandler.instance.REF_USER.observeSingleEvent(of: .value, with: { (snapshot) in
                if let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for user in userSnapshot {
                        if user.key == key {
                            if let username = user.childSnapshot(forPath: "username").value as? String {
                                fbUsername = username
                            }
                        }
                    }
                }
            })
        }
        return fbUsername
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
            if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for game in gameSnapshot {
                    if let gameStarted = game.childSnapshot(forPath: "gameStarted").value as? Bool {
                        if !gameStarted {
                            if game.hasChild("coordinate") {
                                let gameLocationArray = game.childSnapshot(forPath: "coordinate").value as! NSArray
                                let latitude = gameLocationArray[0] as! CLLocationDegrees
                                let longitude = gameLocationArray[1] as! CLLocationDegrees
                                let gameLocation = CLLocation(latitude: latitude, longitude: longitude)
                                let distance = location.distance(from: gameLocation)
                                if distance <= 5 {
                                    if let gameDict = game.value as? Dictionary<String,AnyObject> {
                                        localGames.append(gameDict)
                                    }
                                }
                            }
                        }
                    }
                }
                self.nearbyGames = localGames
            }
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
                                        self.selectedGame = gameDict
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
        var isInGame: Bool = false
        let gameKey = selectedGame["game"] as! String
        GameHandler.instance.REF_GAME.observeSingleEvent(of: .value, with: { (snapshot) in
            if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for game in gameSnapshot {
                    if game.key == gameKey {
                        if let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] {
                            self.players = playersArray
                            if playersArray.count < 4 {
                                for player in playersArray {
                                    if player["username"] as! String == userData["username"] as! String {
                                        isInGame = true
                                        break
                                    }
                                }
                                if isInGame {
                                    self.showAlert(withTitle: "Error:", andMessage: "You're already in that game!")
                                } else {
                                    self.players.append(userData)
                                }
                                
                                var gameToUpdate = selectedGame
                                gameToUpdate["players"] = self.players as AnyObject
                                GameHandler.instance.updateFirebaseDBGame(key: game.key, gameData: gameToUpdate)
                            } else {
                                print("game is full")
                                //TODO: Handle gameIsFull error
                                self.showAlert(withTitle: "Error:", andMessage: "That game is full. Please select a different game.")
                            }
                        }
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
                                if playerUsername != self.username! {
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
        self.players = []
        self.players.append(["username" : self.username as AnyObject,
                             "deck" : player.deck?.rawValue as AnyObject,
                             "victoryPoints" : 0 as AnyObject,
                             "boxVictory" : 0 as AnyObject])
        let gameData: Dictionary<String,Any> = ["game" : self.currentUserID!,
                                                "winCondition" : condition,
                                                "vpGoal" : goal,
                                                "coordinate" : [userLocation?.coordinate.latitude,
                                                                userLocation?.coordinate.longitude],
                                                "username" : self.username!,
                                                "players" : self.players,
                                                "gameStarted" : false,
                                                "currentPlayer" : self.username!]
        GameHandler.instance.updateFirebaseDBGame(key: self.currentUserID!, gameData: gameData)
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            if let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for game in gameSnapshot {
                    if game.key == self.currentUserID! {
                        if let gameDict = game.value as? Dictionary<String,AnyObject> {
                            self.selectedGame = gameDict
                        }
                    }
                }
            }
        })
        self.layoutGameLobby()
        self.observeGamesForNewUsers()
    }
}
