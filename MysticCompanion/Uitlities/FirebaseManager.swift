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

enum FIRKey: String {
    case boxVictory
    case coordinate
    case currentPlayer
    case deck
    case finished
    case game
    case gamesLost
    case gamesPlayed
    case gameStarted
    case gamesWon
    case mostManaGainedInOneTurn
    case mostVPGainedInOneTurn
    case mostVPGainedInOneGame
    case players
    case provider
    case username
    case victoryPoints
    case vpGoal
    case userHasQuitGame
    case winCondition
    case winPercentage
}

enum FIRBranch: String {
    case data
    case game
    case user
}

class FirebaseManager: NSObject {
    // MARK: - Completion Handlers
    typealias BranchFetchCompletion = ([[String : Any]]) -> Void
    typealias FetchCompletion = ([String : Any]) -> Void
    
    private var wrongPasswordCount = 0
    private var email = ""
    private var password = ""
    
    var delegate: UIViewController!
    var currentUserID: String?
    
    var username = "" {
        didSet {
            Player.instance.username = username
            
            if let home = delegate as? HomeVC {
                home.playerName.text = username
            }
        }
    }
    
    var nearbyGames = [[String : Any]]() {
        didSet {
            if let home = delegate as? HomeVC {
                home.gameLobbyTable.animate()
            }
        }
    }
    
    var players = [[String : Any]]() {
        didSet {
            if let home = delegate as? HomeVC {
                home.gameLobbyTable.animate()
            }
        }
    }
    
    override init() {
        super.init()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentUserID = FIRAuth.auth()?.currentUser?.uid
            self.checkUsername()
        }
    }
    
    //-------------------------------
    // MARK: - Authoriation Functions
    //-------------------------------
    /// Logs user in with Firebase using the user-specified username, email, and password
    func loginWithFirebase(username: String, email: String, password: String) {
        guard let loginVC = delegate as? LoginVC else { return }
        self.username = username
        self.email =    email
        self.password = password
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                guard let user = user else { return }
                let userData: [String : Any] = [FIRKey.provider.rawValue : user.providerID,
                                                FIRKey.username.rawValue : username]
                GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                loginVC.dismiss(animated: true, completion: nil)
            } else {
                self.handleFIRError(error)
            }
        })
    }
    
    /// Logs the user in via the selected credential
    /// - parameter credential: The credential specified by the user
    func login(withCredential credential: FIRAuthCredential) {
        guard let loginVC = delegate as? LoginVC else { return }
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                self.handleFIRError(error)
                return
            }
            
            guard let user = user else { return }
            let userData: [String : Any] = [FIRKey.provider.rawValue : credential.provider,
                                            FIRKey.username.rawValue : user.displayName as Any,
                                            FIRKey.mostManaGainedInOneTurn.rawValue : 0,
                                            FIRKey.mostVPGainedInOneTurn.rawValue : 0,
                                            FIRKey.gamesPlayed.rawValue : 0,
                                            FIRKey.gamesWon.rawValue : 0,
                                            FIRKey.gamesLost.rawValue : 0,
                                            FIRKey.mostVPGainedInOneGame.rawValue : 0]
            GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
            loginVC.defaults.set(user.displayName, forKey: FIRKey.username.rawValue)
            loginVC.dismiss(animated: true, completion: nil)
        })
    }
    
    private func checkUsername() {
        if currentUserID == nil {
            username = generateID()
        } else {
            fetchData(on: .user, withKey: currentUserID!) { (fetchedUser) in
                self.username = fetchedUser[FIRKey.username.rawValue] as? String ?? self.generateID()
            }
        }
    }
    
    func observeGames() {
        let key = GameHandler.instance.game[FIRKey.game.rawValue] as? String ?? ""
        
        GameHandler.instance.REF_GAME.observe(.value) { (snapshot) in
            var localGames = [[String : Any]]()
            
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == key {
                    self.fetchData(on: .game, withKey: game.key, completion: { (fetchedGame) in
                        GameHandler.instance.game = fetchedGame
                        self.players = fetchedGame[FIRKey.players.rawValue] as? [[String : Any]] ?? [[ : ]]
                        
                        let gameStarted = fetchedGame[FIRKey.gameStarted.rawValue] as? Bool ?? false
                        if gameStarted {
                            self.delegate.performSegue(withIdentifier: "startGame", sender: nil)
                        }
                    })
                } else {
                    self.fetchData(on: .game, withKey: game.key, completion: { (foundGame) in
                        let gameStarted = foundGame[FIRKey.gameStarted.rawValue] as? Bool ?? true
                        if !gameStarted {
                            guard let coordinates = foundGame[FIRKey.coordinate.rawValue] as? [CLLocationDegrees] else { return }
                            guard let homeVC = self.delegate as? HomeVC, let currentLocation = homeVC.locationManager.currentLocation else {
                                self.delegate.showAlert(.locationNotFound)
                                return
                            }
                            
                            let gameLocation = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
                            let distance = currentLocation.distance(from: gameLocation)
                            if distance <= 30.0 {
                                localGames.append(foundGame)
                            }
                        }
                        self.nearbyGames = localGames
                    })
                }
            }
        }
    }
    
    func hostGame(withWinCondition condition: String, andVPGoal goal: Int) {
        guard let homeVC = delegate as? HomeVC else { return }
        let currentLocation = homeVC.locationManager.currentLocation
        let hostData: [String : Any] = [FIRKey.username.rawValue :        username,
                                        FIRKey.deck.rawValue :            Player.instance.deck.rawValue,
                                        FIRKey.finished.rawValue :        false,
                                        FIRKey.victoryPoints.rawValue :   0,
                                        FIRKey.userHasQuitGame.rawValue : false,
                                        FIRKey.boxVictory.rawValue :      0]
        let gameData: [String : Any] = [FIRKey.game.rawValue :            currentUserID!,
                                        FIRKey.winCondition.rawValue :    condition,
                                        FIRKey.vpGoal.rawValue :          goal,
                                        FIRKey.coordinate.rawValue :      [currentLocation?.coordinate.latitude, currentLocation?.coordinate.longitude],
                                        FIRKey.username.rawValue :        username,
                                        FIRKey.players.rawValue :         [hostData],
                                        FIRKey.gameStarted.rawValue :     false,
                                        FIRKey.currentPlayer.rawValue :   username]
        
        GameHandler.instance.updateFirebaseDBGame(key: currentUserID!, gameData: gameData)
        fetchData(on: .game, withKey: currentUserID!) { (foundGame) in
            GameHandler.instance.game = foundGame
            self.observeGames()
        }
    }
    
    func joinGame(withUserData userData: [String : Any]) {
        print("GAME: Game selected! Getting infomation...")
        let key = GameHandler.instance.game[FIRKey.game.rawValue] as? String ?? ""
        let username = userData[FIRKey.username.rawValue] as? String ?? ""
        let userDeck = userData[FIRKey.deck.rawValue] as? String ?? ""
        var isInGame = false
        var deckTaken = false
        
        fetchData(on: .game, withKey: key) { (fetchedGame) in
            var currentPlayersArray = fetchedGame[FIRKey.players.rawValue] as? [[String : Any]] ?? [[ : ]]
            if currentPlayersArray.count >= 4 {
                self.delegate.showAlert(.gameIsFull)
            } else {
                for player in currentPlayersArray {
                    let playerUsername = player[FIRKey.username.rawValue] as? String ?? ""
                    let playerDeck = player[FIRKey.deck.rawValue] as? String ?? ""
                    
                    if playerUsername == username {
                        isInGame = true
                        break
                    }
                    
                    if playerDeck == userDeck {
                        deckTaken = true
                        break
                    }
                }
                
                if isInGame {
                    let alertController = UIAlertController(title: "View Statistics", message: nil, preferredStyle: .actionSheet)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                    for player in currentPlayersArray {
                        let username = player[FIRKey.username.rawValue] as? String ?? ""
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
                    currentPlayersArray.append(userData)
                    
                    var updatedGame = fetchedGame
                    updatedGame[FIRKey.players.rawValue] = currentPlayersArray
                    GameHandler.instance.updateFirebaseDBGame(key: key, gameData: updatedGame)
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
                let fetchedUsername = user.childSnapshot(forPath: FIRKey.username.rawValue).value as? String ?? ""
                if fetchedUsername == username {
                    let gamesPlayed = user.childSnapshot(forPath: FIRKey.gamesPlayed.rawValue).value as? Int ?? 0
                    let gamesLost = user.childSnapshot(forPath: FIRKey.gamesLost.rawValue).value as? Int ?? 0
                    let gamesWon = user.childSnapshot(forPath: FIRKey.gamesWon.rawValue).value as? Int ?? 0
                    let mostManaGainedInOneTurn = user.childSnapshot(forPath: FIRKey.mostManaGainedInOneTurn.rawValue).value as? Int ?? 0
                    let mostVPGainedInOneGame = user.childSnapshot(forPath: FIRKey.mostVPGainedInOneGame.rawValue).value as? Int ?? 0
                    let mostVPGainedInOneTurn = user.childSnapshot(forPath: FIRKey.mostVPGainedInOneTurn.rawValue).value as? Int ?? 0
                    let winPercentage = self.calculateWinPercentage(gamesPlayed: gamesPlayed, gamesWon: gamesWon)
                    
                    let userStatistics: [String : AnyObject] = [FIRKey.username.rawValue : fetchedUsername as AnyObject,
                                                                FIRKey.winPercentage.rawValue : winPercentage as AnyObject,
                                                                FIRKey.gamesPlayed.rawValue : gamesPlayed as AnyObject,
                                                                FIRKey.gamesLost.rawValue : gamesLost as AnyObject,
                                                                FIRKey.gamesWon.rawValue : gamesWon as AnyObject,
                                                                FIRKey.mostManaGainedInOneTurn.rawValue : mostManaGainedInOneTurn as AnyObject,
                                                                FIRKey.mostVPGainedInOneGame.rawValue : mostVPGainedInOneGame as AnyObject,
                                                                FIRKey.mostVPGainedInOneTurn.rawValue : mostVPGainedInOneTurn as AnyObject]
                    
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
    
    private func fetchAllData(on branch: FIRBranch, completion: @escaping BranchFetchCompletion) {
        var fetchedData = [[String : Any]]()
        
        GameHandler.instance.REF_BASE.child(branch.rawValue).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for snap in snapshot {
                if let snapDict = snap.value as? [String : Any] {
                    fetchedData.append(snapDict)
                }
            }
            completion(fetchedData)
        }
    }
    
    private func fetchData(on branch: FIRBranch, withKey key: String, completion: @escaping FetchCompletion) {
        GameHandler.instance.REF_BASE.child(branch.rawValue).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for snap in snapshot {
                if snap.key == key {
                    if let snapDict = snap.value as? [String : Any] {
                        completion(snapDict)
                    }
                }
            }
        }
    }
    
    private func handleFIRError(_ error: Error?) {
        if let error = error {
            guard let errorCode = FIRAuthErrorCode(rawValue: error._code) else { return }
            switch errorCode {
            case .errorCodeUserNotFound:
                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                    if error != nil {
                        self.handleFIRError(error)
                        return
                    }
                    
                    guard let user = user else { return }
                    let userData: [String : Any] = [FIRKey.provider.rawValue : user.providerID,
                                                    FIRKey.username.rawValue : self.username,
                                                    FIRKey.mostManaGainedInOneTurn.rawValue : 0,
                                                    FIRKey.mostVPGainedInOneTurn.rawValue : 0,
                                                    FIRKey.gamesPlayed.rawValue : 0,
                                                    FIRKey.gamesWon.rawValue : 0,
                                                    FIRKey.gamesLost.rawValue : 0,
                                                    FIRKey.mostVPGainedInOneGame.rawValue : 0]
                    GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                    FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: nil)
                    self.delegate.dismiss(animated: true, completion: nil)
                })
            case .errorCodeWrongPassword:
                self.wrongPasswordCount += 1
                if self.wrongPasswordCount >= 3 {
                    GameHandler.instance.userEmail = email
                    delegate.showAlert(.resetPassword)
                } else {
                    delegate.showAlert(.wrongPassword)
                }
            case .errorCodeEmailAlreadyInUse:                       delegate.showAlert(.emailAlreadyInUse)
            case .errorCodeInvalidEmail:                            delegate.showAlert(.invalidEmail)
            case .errorCodeCredentialAlreadyInUse:                  delegate.showAlert(.credentialInUse)
            case .errorCodeAccountExistsWithDifferentCredential:    delegate.showAlert(.credentialMismatch)
            case .errorCodeInvalidCredential:                       delegate.showAlert(.invalidCredential)
            default:                                                delegate.showAlert(.firebaseError)
            }
        }
    }
}
