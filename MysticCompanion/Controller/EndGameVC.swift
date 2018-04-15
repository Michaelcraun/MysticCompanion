//
//  EndGameVC.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

import GMStepper
import KCFloatingActionButton

import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleMobileAds

class EndGameVC: UIViewController, Alertable, Connection {
    //MARK: - Game Variables
    enum GameState {
        case vpNeeded
        case vpSubmitted
        case gameFinalized
    }
    var gameState: GameState = .vpNeeded {
        didSet {
            switch gameState {
            case .vpNeeded: shouldDisplayStepper = true
            case .vpSubmitted: shouldDisplayStepper = false
            case .gameFinalized: shouldDisplayStepper = false
            }
        }
    }
    
    //MARK: - Firebase Variables
    var players = [Dictionary<String,AnyObject>]() {
        didSet {
            playersTable.animate()
        }
    }
    
    //MARK: - UI Variables
    let playersTable = UITableView()
    let adBanner = GADBannerView()
    let menuButton = KCFloatingActionButton()
    var shouldDisplayStepper = true
    var winnersArray = [String]()
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGameAndObserve()
        layoutView()
        beginConnectionTest()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showAlert(.endOfGame)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton(gameState: gameState)
        beginConnectionTest()
    }
    
    /// Removes the GMStepper and updates the Firebase game with the amount of VP contained within their deck
    func donePressed() {
        let stepper = self.view.viewWithTag(4040) as! GMStepper
        let deckVP = Int(stepper.value)
        
        updateUser(Player.instance.username, withDeckVP: deckVP)
        playersTable.animate()
        layoutMenuButton(gameState: .vpSubmitted)
    }
    
    /// Handles exiting the game and displaying the HomeVC
    func quitPressed() {
        GameHandler.instance.REF_GAME.removeAllObservers()
        dismissPreviousViewControllers()
    }
}

//---------------
// MARK: - Layout
//---------------
extension EndGameVC {
    /// The central point of layout methods
    private func layoutView() {
        setBackgroundImage(#imageLiteral(resourceName: "endGameBG"))
        layoutPlayersTable()
        layoutMenuButton(gameState: gameState)
        layoutAds()
    }
    
    /// Configures the players table
    private func layoutPlayersTable() {
        playersTable.dataSource = self
        playersTable.delegate = self
        playersTable.allowsSelection = false
        playersTable.register(EndGamePlayersCell.self, forCellReuseIdentifier: "endGamePlayersCell")
        playersTable.separatorStyle = .none
        playersTable.backgroundColor = .clear
        playersTable.translatesAutoresizingMaskIntoConstraints = false
        
        var tableBottomBuffer: CGFloat {
            switch PREMIUM_PURCHASED {
            case true: return menuButton.frame.height + 30
            case false: return adBanner.frame.height + menuButton.frame.height + 40
            }
        }
        
        playersTable.anchorTo(view, top: view.topAnchor,
                              bottom: view.bottomAnchor,
                              leading: view.leadingAnchor,
                              trailing: view.trailingAnchor,
                              padding: .init(top: topLayoutConstant, left: 10, bottom: -tableBottomBuffer, right: -10))
        
        playersTable.animate()
    }
    
    /// Configures the KCFloatingActionButton with a specific game state
    /// - parameter gameState: The specified GameState to configure for
    private func layoutMenuButton(gameState: GameState) {
        self.gameState = gameState
        
        menuButton.setMenuButtonColor()
        menuButton.setPaddingY(viewHasAds: true)
        menuButton.items = []
        
        let settings = KCFloatingActionButtonItem()
        settings.setButtonOfType(.settings)
        settings.handler = { item in
            self.performSegue(withIdentifier: "showSettings", sender: nil)
        }
        
        let done = KCFloatingActionButtonItem()
        done.setButtonOfType(.done)
        done.handler = { item in
            self.donePressed()
        }
        
        let quit = KCFloatingActionButtonItem()
        quit.setButtonOfType(.quitGame)
        quit.handler = { item in
            self.quitPressed()
        }
        
        let share = KCFloatingActionButtonItem()
        share.setButtonOfType(.share)
        share.handler = { item in
            self.shareGame(withWinners: self.winnersArray)
        }
        
        menuButton.addItem(item: settings)
        if gameState == .vpNeeded {
            menuButton.addItem(item: done)
        } else if gameState == .gameFinalized {
            menuButton.addItem(item: quit)
            menuButton.addItem(item: share)
        }
        
        menuButton.anchorTo(view)
    }
    
    /// If user hasn't purchased premium, configures ads and constrains the banner to the bottom of the screen
    private func layoutAds() {
        if !PREMIUM_PURCHASED {
            adBanner.adUnitID = "ca-app-pub-4384472824519738/9844119805"  //My ads
//            adBanner.adUnitID = "ca-app-pub-3940256099942544/6300978111"    //Test ads
            adBanner.backgroundColor = .white
            adBanner.rootViewController = self
            adBanner.load(GADRequest())
            adBanner.anchorTo(view,
                              bottom: view.bottomAnchor,
                              leading: view.leadingAnchor,
                              trailing: view.trailingAnchor,
                              padding: .init(top: 0, left: 0, bottom: bottomLayoutConstant, right: 0),
                              size: .init(width: 0, height: 50))
        }
    }
}

//------------------------------------------
// MARK: - TableView DataSource and Delegate
//------------------------------------------
extension EndGameVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "endGamePlayersCell") as! EndGamePlayersCell
        cell.configureCell(forPlayer: players[indexPath.row], shouldDisplayStepper: shouldDisplayStepper, withWinners: winnersArray)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return playersTable.frame.height / CGFloat(players.count)
    }
}

//-----------------
// MARK: - Firebase
//-----------------
extension EndGameVC {
    /// Configures game on Firebase and begins observing
    private func setupGameAndObserve() {
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
                            GameHandler.instance.createFirebaseDBData(forGame: currentUID, withPlayers: playersArray, andWinners: winnersArray, andDateString: nil)
                        }
                    }
                }
            }
        })
    }
    
    /// Updates a specific user's data with their deck's victory points
    /// - parameter user: A String value representing the user's username
    /// - parameter deckVP: An Int value representing the user's victory points contained within their deck
    private func updateUser(_ user: String, withDeckVP deckVP: Int) {
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
    
    /// Updates a user's statistics after the game is over
    /// - parameter player: An Array of Dictionary values containing the game's players' data
    /// - parameter winners: An Array of String values containing the usernames of the winner(s) of the game
    private func updateFBUserStatistics(withPlayers players: [[String : AnyObject]], andWinners winners: [String]) {
        var userData = Dictionary<String,AnyObject>()
        var gamesPlayed = 0
        var gamesWon = 0
        var gamesLost = 0
        
        GameHandler.instance.REF_USER.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == FIRAuth.auth()?.currentUser?.uid {
                    if let firebaseUser = user.value as? [String : AnyObject] { userData = firebaseUser }
                    if let firebaseGamesPlayed = userData["gamesPlayed"] as? Int { gamesPlayed = firebaseGamesPlayed }
                    if let firebaseGamesWon = userData["gamesWon"] as? Int { gamesWon = firebaseGamesWon }
                    if let firebaseGamesLost = userData["gamesLost"] as? Int { gamesLost = firebaseGamesLost }
                    guard let firebaseMostVPGainedInOneGame = userData["mostVPGainedInOneGame"] as? Int else { return }
                    
                    gamesPlayed += 1
                    var userHasWonGame = false
                    for winner in winners {
                        if winner == Player.instance.username {
                            userHasWonGame = true
                            break
                        }
                    }
                    
                    if userHasWonGame {
                        gamesWon += 1
                    } else {
                        gamesLost += 1
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
