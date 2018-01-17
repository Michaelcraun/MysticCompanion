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
import FirebaseAuth

extension HomeVC {
    func checkUsername(forKey key: String?) {
        if let defaultsUsername = defaults.string(forKey: "username") {
            Player.instance.username = defaultsUsername
            playerName.text = defaultsUsername
        }
        
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
        
        for _ in 0..<10 {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            userID += String(newCharacter)
        }
        return userID
    }
    
    //MARK: Firebase observers for user -- observes game directory for games that haven't
    //started and are within 5 meters of the user
    func observeForNearbyGames() {
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            let userLocation = self.locationManager.location
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
                        
                        let distance = userLocation!.distance(from: gameLocation)
                        if distance <= 5.0 {
                            guard let gameDict = game.value as? Dictionary<String,AnyObject> else { return }
                            localGames.append(gameDict)
                        }
                    }
                }
            }
            self.nearbyGames = localGames
        })
    }
    
    //MARK: Firebase observer for user -- observes for the host starting the game
    func observeGameForStart() {
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
        GameHandler.instance.REF_GAME.observe(.value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    guard let gameStarted = game.childSnapshot(forPath: "gameStarted").value as? Bool else { return }
                    if gameStarted {
                        guard let gameDict = game.value as? Dictionary<String,AnyObject> else { return }
                        GameHandler.instance.game = gameDict
                        self.performSegue(withIdentifier: "startGame", sender: nil)
                    }
                }
            }
        })
    }
    
    //MARK: Firebase observer for host
    func hostGameAndObserve(withWinCondition condition: String, andVPGoal goal: Int) {
        let userLocation = self.locationManager.location
        winCondition = condition
        let hostData = ["username" : Player.instance.username as AnyObject,
                        "deck" : Player.instance.deck.rawValue as AnyObject,
                        "finished" : false as AnyObject,
                        "victoryPoints" : 0 as AnyObject,
                        "userHasQuitGame" : false as AnyObject,
                        "boxVictory" : 0 as AnyObject]
        self.players = [hostData]
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
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == self.currentUserID! {
                    guard let gameDict = game.value as? Dictionary<String,AnyObject> else { return }
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    
                    GameHandler.instance.game = gameDict
                    self.players = playersArray
                }
            }
        })
        self.layoutGameLobby()
    }
    
    func updateGame(withUserData userData: Dictionary<String,AnyObject>) {
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
        guard let userUsername = userData["username"] as? String else { return }
        guard let userDeck = userData["deck"] as? String else { return }
        var isInGame = false
        var deckTaken = false
        
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
                        
                        if isInGame {
                            self.showAlert(.userExistsInGame)
                        } else if deckTaken {
                            self.showAlert(.deckTaken)
                        } else {
                            self.players.append(userData)
                        }
                        
                        GameHandler.instance.game["players"] = self.players as AnyObject
                        GameHandler.instance.updateFirebaseDBGame(key: game.key, gameData: GameHandler.instance.game)
                    } else {
                        print("game is full")
                        //TODO: Test gameIsFull error
                        self.showAlert(.gameIsFull)
                    }
                }
            }
        })
    }
    
    func convertCoreDataGamesIntoFirebaseEntries() {
        coreDataHasBeenConverted = defaults.bool(forKey: "coreDataHasBeenConverted")
        
        if !coreDataHasBeenConverted {
            attemptGameFetch()
            if let objects = controller.fetchedObjects, objects.count > 0 { coreDataGames = objects }
            for game in coreDataGames {
                guard let coreDataDate = game.date else { return }
                var coreDataPlayers = [Dictionary<String,AnyObject>]()
                var coreDataWinners = [String]()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.dateFormat = "MMDDYYYY HH:mm"
                let dateString = dateFormatter.string(from: coreDataDate)
                
                if let playerName = game.player1, let playerColor = game.player1Color {
                    let player1 = createPlayerFromCoreDataGame(playerName, withDeckColor: playerColor, andVictory: game.player1VP)
                    coreDataPlayers.append(player1)
                }
                
                if let playerName = game.player2, let playerColor = game.player2Color {
                    let player2 = createPlayerFromCoreDataGame(playerName, withDeckColor: playerColor, andVictory: game.player2VP)
                    coreDataPlayers.append(player2)
                }
                
                if let playerName = game.player3, let playerColor = game.player3Color {
                    let player3 = createPlayerFromCoreDataGame(playerName, withDeckColor: playerColor, andVictory: game.player3VP)
                    coreDataPlayers.append(player3)
                }
                
                if let playerName = game.player4, let playerColor = game.player4Color {
                    let player4 = createPlayerFromCoreDataGame(playerName, withDeckColor: playerColor, andVictory: game.player4VP)
                    coreDataPlayers.append(player4)
                }
                
                var winningVP = 0
                for player in coreDataPlayers {
                    guard let username = player["username"] as? String else { return }
                    guard let victoryPoints = player["victoryPoints"] as? Int else { return }
                    if victoryPoints > winningVP {
                        winningVP = victoryPoints
                        coreDataWinners = [username]
                    } else if victoryPoints == winningVP {
                        coreDataWinners.append(username)
                    }
                }
                
                GameHandler.instance.createFirebaseDBData(forGame: (FIRAuth.auth()?.currentUser?.uid)!,
                                                          withPlayers: coreDataPlayers,
                                                          andWinners: coreDataWinners,
                                                          andDateString: dateString)
            }
            defaults.set(true, forKey: "coreDataHasBeenConverted")
        }
    }
    
    func getDeckTypeFromCoreDataGame(forColor color: String) -> String {
        var playerDeck: String {
            switch color {
            case "red": return "beastbrothers"
            case "yellow": return "dawnseekers"
            case "green": return "lifewardens"
            case "blue": return "waveguards"
            default: return ""
            }
        }
        
        return playerDeck
    }
    
    func createPlayerFromCoreDataGame(_ username: String, withDeckColor color: String, andVictory victory: Int16) -> Dictionary<String,AnyObject> {
        let player: Dictionary<String,AnyObject> = ["username"         : username as AnyObject,
                                                    "deck"             : getDeckTypeFromCoreDataGame(forColor: color) as AnyObject,
                                                    "victoryPoints"    : victory as AnyObject]
        
        return player
    }
}
