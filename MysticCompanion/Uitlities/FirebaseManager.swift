//
//  FirebaseManager.swift
//  MysticCompanion
//
//  Created by Michael Craun on 4/18/18.
//  Copyright © 2018 Craunic Productions. All rights reserved.
//

import Foundation
import MapKit

import Firebase
import FirebaseAuth
import FirebaseDatabase

class FirebaseManager: NSObject {
    let locationManager = LocationManager()
    
    var delegate: UIViewController!
    var currentUserID: String?
    
    var username: String! {
        didSet {
            if let home = delegate as? HomeVC {
                home.playerName.text = username
            }
        }
    }
    
    var currentGame = [String : Any]() {
        didSet {
            let key = currentGame["game"] as? String ?? ""
            GameHandler.instance.updateFirebaseDBGame(key: key, gameData: currentGame)
            
            
        }
    }
    
    var nearbyGames = [[String : Any]]() {
        didSet {
            
        }
    }
    
    override init() {
        super.init()
        
        locationManager.delegate = delegate
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentUserID = FIRAuth.auth()?.currentUser?.uid
            self.checkUsername()
        }
    }
    
    private func checkUsername() {
        if currentUserID == nil {
            username = generateID()
        } else {
            GameHandler.instance.REF_USER.observeSingleEvent(of: .value) { (snapshot) in
                guard let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
                for user in userSnapshot {
                    if user.key == self.currentUserID! {
                        let username = user.childSnapshot(forPath: "username").value as? String ?? self.generateID()
                        self.username = username
                    }
                }
            }
        }
    }
    
    func observeGames() {
        let key = currentGame["game"] as? String ?? ""
        var localGames = [[String : Any]]()
        
        GameHandler.instance.REF_GAME.observe(.value) { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                // MARK: Fetches the current game data from Firebase
                let gameKey = game.childSnapshot(forPath: "game").value as? String ?? ""
                if gameKey == key {
                    let gameStarted = game.childSnapshot(forPath: "gameStarted").value as? Bool ?? false
                    if gameStarted {
                        self.currentGame = game.value as? [String : Any] ?? [ : ]
                        self.delegate.performSegue(withIdentifier: "startGame", sender: nil)
                    }
                    
                    let fetchedGame = game.value as? [String : Any] ?? [ : ]
                    self.currentGame = fetchedGame
                }
                
                // MARK: Fetches any nearby games that haven't started, yet, from Firebase
                let gameStarted = game.childSnapshot(forPath: "gameStarted").value as? Bool ?? true
                if !gameStarted {
                    if game.hasChild("coordinate") {
                        let currentLocation = self.locationManager.currentLocation
                        let gameLocationArray = game.childSnapshot(forPath: "coordinate").value as! NSArray
                        let latitude = gameLocationArray[0] as! CLLocationDegrees
                        let longitude = gameLocationArray[1] as! CLLocationDegrees
                        let gameLocation = CLLocation(latitude: latitude, longitude: longitude)
                        
                        let distance = currentLocation!.distance(from: gameLocation)
                        if distance <= 30.0 {
                            let gameDict = game.value as? [String : Any] ?? [ : ]
                            localGames.append(gameDict)
                        }
                    }
                }
            }
            self.nearbyGames = localGames
        }
    }
    
    func hostGame(withWinCondition condition: String, andVPGoal goal: Int) {
        let currentLocation = self.locationManager.currentLocation
        let hostData: [String : Any] = ["username" :        username,
                                        "deck" :            Player.instance.deck.rawValue,
                                        "finished" :        false,
                                        "victoryPoints" :   0,
                                        "userHasQuitGame" : false,
                                        "boxVictory" :      0]
        let gameData: [String : Any] = ["game" :            currentUserID!,
                                        "winCondition" :    condition,
                                        "vpGoal" :          goal,
                                        "coordinate" :      [currentLocation?.coordinate.latitude, currentLocation?.coordinate.longitude],
                                        "username" :        username,
                                        "players" :         [hostData],
                                        "gameStarted" :     false,
                                        "currentPlayer" :   username]
        
        GameHandler.instance.updateFirebaseDBGame(key: currentUserID!, gameData: gameData)
        GameHandler.instance.REF_GAME.observeSingleEvent(of: .value) { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == self.currentUserID! {
                    let game = game.value as? [String : Any] ?? [ : ]
                    self.currentGame = game
                    self.observeGames()
                }
            }
        }
    }
    
    func joinGame(withUserData userData: [String : Any]) {
        let key = currentGame["game"] as? String ?? ""
        let username = userData["username"] as? String ?? ""
        let userDeck = userData["deck"] as? String ?? ""
        var isInGame = false
        var deckTaken = false
        
        GameHandler.instance.REF_GAME.observeSingleEvent(of: .value) { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == key {
                    let currentPlayersArray = game.childSnapshot(forPath: "players").value as? [[String : Any]] ?? [[ : ]]
                    if currentPlayersArray.count > 4 {
                        self.delegate.showAlert(.gameIsFull)
                    } else {
                        for player in currentPlayersArray {
                            let playerUsername = player["username"] as? String ?? ""
                            if playerUsername == username {
                                isInGame = true
                                break
                            }
                            
                            let playerDeck = player["deck"] as? String ?? ""
                            if playerDeck == userDeck {
                                deckTaken = true
                                break
                            }
                            
                            if isInGame {
                                let alertController = UIAlertController(title: "View Statistics", message: nil, preferredStyle: .actionSheet)
                                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                                for player in currentPlayersArray {
                                    let username = player["username"] as? String ?? ""
                                    let playerAction = UIAlertAction(title: "\(username)", style: .default, handler: { (action) in
                                        self.observeUserStatisticsForUser(username)
                                    })
                                    alertController.addAction(playerAction)
                                }
                                alertController.addAction(cancelAction)
                                
                                self.delegate.present(alertController, animated: true, completion: nil)
                            } else if deckTaken {
                                self.delegate.showAlert(.deckTaken)
                            } else {
                                GameHandler.instance.REF_GAME.observeSingleEvent(of: .value, with: { (snapshot) in
                                    guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
                                    for game in gameSnapshot {
                                        let gameKey = game.key
                                    }
                                })
                                self.currentGame = GameHandler.instance.REF_GAME.value(forKey: game.key) as? [String : Any] ?? [ : ]
                                self.currentGame["players"] = {
                                    var playersArray = self.currentGame["players"] as? [[String : Any]] ?? [[ : ]]
                                    playersArray.append(userData)
                                    return playersArray
                                }()
                                
                                self.observeGames()
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Fetches a specific user's game statistics and presents them to the current user
    /// - parameter username: A String value representing the selected user's username
    func observeUserStatisticsForUser(_ username: String) {
        GameHandler.instance.REF_USER.observeSingleEvent(of: .value) { (snapshot) in
            guard let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for user in userSnapshot {
                let fetchedUsername = user.childSnapshot(forPath: "username").value as? String ?? ""
                if fetchedUsername == username {
                    let gamesPlayed = user.childSnapshot(forPath: "gamesPlayed").value as? Int ?? 0
                    let gamesLost = user.childSnapshot(forPath: "gamesLost").value as? Int ?? 0
                    let gamesWon = user.childSnapshot(forPath: "gamesWon").value as? Int ?? 0
                    let mostManaGainedInOneTurn = user.childSnapshot(forPath: "mostManaGainedInOneTurn").value as? Int ?? 0
                    let mostVPGainedInOneGame = user.childSnapshot(forPath: "mostVPGainedInOneGame").value as? Int ?? 0
                    let mostVPGainedInOneTurn = user.childSnapshot(forPath: "mostVPGainedInOneTurn").value as? Int ?? 0
                    let winPercentage = self.calculateWinPercentage(gamesPlayed: gamesPlayed, gamesWon: gamesWon)
                    
                    let userStatistics: [String : AnyObject] = ["username" : fetchedUsername as AnyObject,
                                                                "winPercentage" : winPercentage as AnyObject,
                                                                "gamesPlayed" : gamesPlayed as AnyObject,
                                                                "gamesLost" : gamesLost as AnyObject,
                                                                "gamesWon" : gamesWon as AnyObject,
                                                                "mostManaGainedInOneTurn" : mostManaGainedInOneTurn as AnyObject,
                                                                "mostVPGainedInOneGame" : mostVPGainedInOneGame as AnyObject,
                                                                "mostVPGainedInOneTurn" : mostVPGainedInOneTurn as AnyObject]
                    
                    let statisticsView = StatisticsView()
                    statisticsView.layoutWithStatistics(userStatistics)
                    self.delegate.view.addSubview(statisticsView)
                }
            }
        }
    }
}

//--------------------------
// MARK: - Private functions
//--------------------------
extension FirebaseManager {
    private func generateID() -> String {
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
    
    /// Calculates and a specific user's win percentage, according the the games the user has played and the games the
    /// user has won
    /// - parameter gamesPlayed: An Int value representing the amount of games the user has played
    /// - parameter gamesWon: An Int value representing the amount of games the user has won
    private func calculateWinPercentage(gamesPlayed: Int, gamesWon: Int) -> Double {
        if gamesPlayed > 0 {
            let winPercentage = Double(gamesWon) / Double(gamesPlayed) * 100
            return winPercentage
        }
        return 0.0
    }
}
