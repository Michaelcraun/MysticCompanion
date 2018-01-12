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
                        "deck" : Player.instance.deck?.rawValue as AnyObject,
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
                        
                        //TODO: Check if user is in game AND their deck is taken and switch deck out if deck isn't taken ?
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
    
    func convertCoreDataGameIntoFirebaseEntry(forGame game: Game) {
        guard let coreDataDate = game.date else { return }
        var coreDataGame = Dictionary<String,AnyObject>()
        var coreDataPlayers = [Dictionary<String,AnyObject>]()
        var coreDataWinners = [String]()
        var player1: Dictionary<String,AnyObject> = ["username" : "" as AnyObject,
                                                     "deck" : "" as AnyObject,
                                                     "victoryPoints": 0 as AnyObject,
                                                     "bocVictory" : 0 as AnyObject]
        var player2: Dictionary<String,AnyObject> = ["username" : "" as AnyObject,
                                                     "deck" : "" as AnyObject,
                                                     "victoryPoints": 0 as AnyObject,
                                                     "bocVictory" : 0 as AnyObject]
        var player3: Dictionary<String,AnyObject> = ["username" : "" as AnyObject,
                                                     "deck" : "" as AnyObject,
                                                     "victoryPoints": 0 as AnyObject,
                                                     "bocVictory" : 0 as AnyObject]
        var player4: Dictionary<String,AnyObject> = ["username" : "" as AnyObject,
                                                     "deck" : "" as AnyObject,
                                                     "victoryPoints": 0 as AnyObject,
                                                     "bocVictory" : 0 as AnyObject]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "MMDDYYYY HH:mm"
        let dateString = dateFormatter.string(from: coreDataDate)
        
        if let playerName = game.player1, let playerColor = game.player1Color {
            var playerDeck: String {
                switch playerColor {
                case "red": return "beastbrothers"
                case "yellow": return "dawnseekers"
                case "green": return "lifewardens"
                case "blue": return "waveguards"
                default: return ""
                }
            }
            
            player1["username"] = playerName as AnyObject
            player1["deck"] = playerDeck as AnyObject
            player1["victoryPoints"] = game.player1VP as AnyObject
            coreDataPlayers.append(player1)
        }
        
        if let playerName = game.player2, let playerColor = game.player2Color {
            var playerDeck: String {
                switch playerColor {
                case "red": return "beastbrothers"
                case "yellow": return "dawnseekers"
                case "green": return "lifewardens"
                case "blue": return "waveguards"
                default: return ""
                }
            }
            
            player2["username"] = playerName as AnyObject
            player2["deck"] = playerDeck as AnyObject
            player2["victoryPoints"] = game.player2VP as AnyObject
            coreDataPlayers.append(player2)
        }
        
        if let playerName = game.player3, let playerColor = game.player3Color {
            var playerDeck: String {
                switch playerColor {
                case "red": return "beastbrothers"
                case "yellow": return "dawnseekers"
                case "green": return "lifewardens"
                case "blue": return "waveguards"
                default: return ""
                }
            }
            
            player3["username"] = playerName as AnyObject
            player3["deck"] = playerDeck as AnyObject
            player3["victoryPoints"] = game.player3VP as AnyObject
            coreDataPlayers.append(player3)
        }
        
        if let playerName = game.player4, let playerColor = game.player4Color {
            var playerDeck: String {
                switch playerColor {
                case "red": return "beastbrothers"
                case "yellow": return "dawnseekers"
                case "green": return "lifewardens"
                case "blue": return "waveguards"
                default: return ""
                }
            }
            
            player4["username"] = playerName as AnyObject
            player4["deck"] = playerDeck as AnyObject
            player4["victoryPoints"] = game.player4VP as AnyObject
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
}
