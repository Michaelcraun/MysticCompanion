//
//  GameVC.swift
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

class GameVC: UIViewController, Alertable, Connection {
    //MARK: - UI Variables
    let playerPanel = UIView()
    let gameVPLabel = UILabel()
    let playersTable = UITableView()
    let adBanner = GADBannerView()
    
    let manaTracker = TrackerView()
    let decayTracker = TrackerView()
    let growthTracker = TrackerView()
    let animalTracker = TrackerView()
    let forestTracker = TrackerView()
    let skyTracker = TrackerView()
    let victoryTracker = TrackerView()
    let wildTracker = TrackerView()
    var trackersArray = [TrackerView]()

    //MARK: - Game Variables
    var isEndOfGameTurn = false
    var userHasQuitGame = false
    var endingPlayerUsername = ""
    var currentVP = 0
    var vpFromTurn = 0
    var vpGoal = 13 {
        didSet {
            gameVPLabel.text = "Victory Point Pool: \(victoryTaken)/\(vpGoal)"
        }
    }
    
    var victoryTaken = 0 {
        didSet {
            gameVPLabel.text = "Victory Point Pool: \(victoryTaken)/\(vpGoal)"
            let endingPlayer = players[0]
            guard let endingPlayerUsername = endingPlayer["username"] as? String else { return }
            self.endingPlayerUsername = endingPlayerUsername
        }
    }
    
    var players = [Dictionary<String,AnyObject>]() {
        willSet {
            playersTable.animate()
        }
    }
    
    var currentPlayer = "" {
        didSet {
            if currentPlayer == Player.instance.username && currentPlayer != endingPlayerUsername {
                if userHasSpoiled {
                    endPlayerTurn()
                } else {
                    showAlert(.yourTurn)
                }
            }
        }
    }
    
    var userHasSpoiled = false {
        didSet {
            if currentPlayer == Player.instance.username {
                endPlayerTurn()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGameAndObserve()
        layoutView()
        setupPlayerTurn()
        beginConnectionTest()
        saveUserDeck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton()
        beginConnectionTest()
    }
    
    /// If the game has ended, segues to the EndGameVC; otherwise, sets up the user's trackers, according to the Player
    /// class and animates each tracker's alpha to 1
    private func setupPlayerTurn() {
        if isEndOfGameTurn { performSegue(withIdentifier: "showEndGame", sender: nil) }
    
        userHasSpoiled = false
        manaTracker.currentStepper.value = Double(Player.instance.manaConstant)
        manaTracker.constantStepper.value = Double(Player.instance.manaConstant)
        decayTracker.currentStepper.value = Double(Player.instance.decayConstant)
        decayTracker.constantStepper.value = Double(Player.instance.decayConstant)
        growthTracker.currentStepper.value = Double(Player.instance.growthConstant)
        growthTracker.constantStepper.value = Double(Player.instance.growthConstant)
        animalTracker.currentStepper.value = Double(Player.instance.animalConstant)
        animalTracker.constantStepper.value = Double(Player.instance.animalConstant)
        forestTracker.currentStepper.value = Double(Player.instance.forestConstant)
        forestTracker.constantStepper.value = Double(Player.instance.forestConstant)
        skyTracker.currentStepper.value = Double(Player.instance.skyConstant)
        skyTracker.constantStepper.value = Double(Player.instance.skyConstant)
        wildTracker.currentStepper.value = Double(Player.instance.wildConstant)
        wildTracker.constantStepper.value = Double(Player.instance.wildConstant)
        victoryTracker.currentStepper.value = 0
        
        currentVP = Int(victoryTracker.currentStepper.value) + Player.instance.boxVP
        
        var delay: TimeInterval = 0.0
        for i in 0..<trackersArray.count {
            trackersArray[i].fadeAlphaTo(1, withDuration: Double(trackersArray.count) * 0.1, andDelay: delay)
            delay += 0.1
        }
    }
    
    /// If the user hasn't spoiled, saves user's new constants, current VP, and updates Firebase with user's new
    /// statistics. Then, passes the user's turn to the next user
    private func endPlayerTurn() {
        if !userHasSpoiled {
            Player.instance.manaConstant = Int(manaTracker.constantStepper.value)
            Player.instance.decayConstant = Int(decayTracker.constantStepper.value)
            Player.instance.growthConstant = Int(growthTracker.constantStepper.value)
            Player.instance.animalConstant = Int(animalTracker.constantStepper.value)
            Player.instance.forestConstant = Int(forestTracker.constantStepper.value)
            Player.instance.skyConstant = Int(skyTracker.constantStepper.value)
            Player.instance.wildConstant = Int(wildTracker.constantStepper.value)
            Player.instance.currentVP += Int(victoryTracker.currentStepper.value)
            
            let currentMana = Int(manaTracker.currentStepper.value)
            let vpAtEndOfTurn = Int(victoryTracker.currentStepper.value) + Player.instance.boxVP
            vpFromTurn = vpAtEndOfTurn - currentVP
            updateFBUserStatistics(withMana: currentMana, andVictory: vpFromTurn)
        }
        
        let userData: Dictionary<String,AnyObject> = ["username" : Player.instance.username as AnyObject,
                                                      "deck" : Player.instance.deck.rawValue as AnyObject,
                                                      "finished" : false as AnyObject,
                                                      "victoryPoints" : Player.instance.currentVP as AnyObject,
                                                      "boxVictory" : Player.instance.boxVP as AnyObject]
        passTurn(withUserData: userData)
        animateTrackersOut()
    }
    
    /// Animates each of the user's trackers' alpha to 0, one by one, at the end of the user's turn then segues to
    /// EndGameVC if the user caused the end of the game
    func animateTrackersOut() {
        var delay: TimeInterval = 0.0
        for i in 0..<trackersArray.count {
            trackersArray[i].fadeAlphaTo(0, withDuration: Double(trackersArray.count) * 0.1, andDelay: delay)
            delay += 0.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(trackersArray.count) * 0.15) {
            if self.isEndOfGameTurn && self.endingPlayerUsername != Player.instance.username {
                self.performSegue(withIdentifier: "showEndGame", sender: nil)
            } else {
                self.setupPlayerTurn()
            }
        }
    }
    
    /// Indicates that the user has spoiled if the user's decay tracker is more than three more than the user's growth
    /// tracker
    @objc private func checkForSpoil(sender: GMStepper) {
        let currentDecay = decayTracker.currentStepper.value
        let currentGrowth = growthTracker.currentStepper.value
        
        if currentDecay - 3 > currentGrowth && !userHasSpoiled { showAlert(.spoil) }
        sender.reset()
    }
    
    /// Indicates that the game has ended on Firebase
    func endGame() {
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
        GameHandler.instance.updateFirebaseDBGame(key: gameKey, gameData: ["gameEnded" : true])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let victoryIconBounds = victoryTracker.iconView.bounds
        guard let location = touches.first?.location(in: victoryTracker.iconView) else { return }
        
        if location.x >= victoryIconBounds.minX && location.x <= victoryIconBounds.maxX {
            if location.y >= victoryIconBounds.minY && location.y <= victoryIconBounds.maxY {
                showAlert(.victoryChange)
            }
        }
    }
    
    /// Sets the user's deck to what they played this time for quick-starting a new game
    private func saveUserDeck() {
        let defaults = UserDefaults.standard
        defaults.set(Player.instance.deck.rawValue, forKey: "previousDeck")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEndGame" {
            if let destination = segue.destination as? EndGameVC {
                destination.transitioningDelegate = self.transitioningDelegate
                destination.modalPresentationStyle = .custom
                
                GameHandler.instance.REF_GAME.removeAllObservers()
            }
        }
    }
}

//---------------
// MARK: - Layout
//---------------
extension GameVC {
    /// The central point for layout of GameVC
    private func layoutView() {
        layoutBackground()
        layoutPlayersPanel()
        layoutTrackers()
        layoutMenuButton()
        layoutBannerAds()
    }
    
    /// Configures the background image
    private func layoutBackground() {
        let backgroundImage = UIImageView()
        backgroundImage.image = #imageLiteral(resourceName: "gameBG")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.alpha = 0.5
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImage)
        
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    ///Configures the players panel and table
    private func layoutPlayersPanel() {
        let panelHeight = CGFloat(players.count) * 27.5 + 16.5
        
        playerPanel.layer.cornerRadius = 10
        playerPanel.layer.borderColor = UIColor.black.cgColor
        playerPanel.layer.borderWidth = 2
        playerPanel.clipsToBounds = true
        playerPanel.translatesAutoresizingMaskIntoConstraints = false
        
        gameVPLabel.font = UIFont(name: fontFamily, size: 10)
        gameVPLabel.textAlignment = .center
        gameVPLabel.text = "Victory Point Pool: 0/23"
        gameVPLabel.translatesAutoresizingMaskIntoConstraints = false
        
        playersTable.allowsSelection = false
        playersTable.dataSource = self
        playersTable.delegate = self
        playersTable.backgroundColor = .clear
        playersTable.register(PlayersTableCell.self, forCellReuseIdentifier: "playersTableCell")
        playersTable.separatorStyle = .none
        playersTable.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playerPanel)
        playerPanel.addBlurEffect()
        playerPanel.addSubview(gameVPLabel)
        playerPanel.addSubview(playersTable)
        
        playerPanel.topAnchor.constraint(equalTo: view.topAnchor, constant: topLayoutConstant).isActive = true
        playerPanel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        playerPanel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        playerPanel.heightAnchor.constraint(equalToConstant: panelHeight).isActive = true
        
        gameVPLabel.topAnchor.constraint(equalTo: playerPanel.topAnchor, constant: 5).isActive = true
        gameVPLabel.leftAnchor.constraint(equalTo: playerPanel.leftAnchor).isActive = true
        gameVPLabel.rightAnchor.constraint(equalTo: playerPanel.rightAnchor).isActive = true
        
        playersTable.topAnchor.constraint(equalTo: gameVPLabel.bottomAnchor).isActive = true
        playersTable.leftAnchor.constraint(equalTo: playerPanel.leftAnchor).isActive = true
        playersTable.rightAnchor.constraint(equalTo: playerPanel.rightAnchor).isActive = true
        playersTable.bottomAnchor.constraint(equalTo: playerPanel.bottomAnchor).isActive = true
    }
    
    /// Configures the user's trackers
    private func layoutTrackers() {
        let screenWidth = view.frame.width
        let trackerWidth = (screenWidth - 40) / 3
        
        manaTracker.initTrackerOfType(.mana)
        manaTracker.alpha = 0
        manaTracker.translatesAutoresizingMaskIntoConstraints = false
        
        decayTracker.initTrackerOfType(.decay)
        decayTracker.alpha = 0
        decayTracker.currentStepper.addTarget(self, action: #selector(checkForSpoil(sender:)), for: .allEvents)
        decayTracker.translatesAutoresizingMaskIntoConstraints = false
        
        growthTracker.initTrackerOfType(.growth)
        growthTracker.alpha = 0
        growthTracker.currentStepper.addTarget(self, action: #selector(checkForSpoil(sender:)), for: .allEvents)
        growthTracker.translatesAutoresizingMaskIntoConstraints = false
        
        animalTracker.initTrackerOfType(.animal)
        animalTracker.alpha = 0
        animalTracker.translatesAutoresizingMaskIntoConstraints = false
        
        forestTracker.initTrackerOfType(.forest)
        forestTracker.alpha = 0
        forestTracker.translatesAutoresizingMaskIntoConstraints = false
        
        skyTracker.initTrackerOfType(.sky)
        skyTracker.alpha = 0
        skyTracker.translatesAutoresizingMaskIntoConstraints = false
        
        victoryTracker.initTrackerOfType(.victory)
        victoryTracker.alpha = 0
        victoryTracker.translatesAutoresizingMaskIntoConstraints = false
        
        wildTracker.initTrackerOfType(.wild)
        wildTracker.alpha = 0
        wildTracker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(manaTracker)
        view.addSubview(decayTracker)
        view.addSubview(growthTracker)
        view.addSubview(animalTracker)
        view.addSubview(forestTracker)
        view.addSubview(skyTracker)
        view.addSubview(victoryTracker)
        view.addSubview(wildTracker)
        
        decayTracker.topAnchor.constraint(equalTo: playerPanel.bottomAnchor, constant: 40).isActive = true
        decayTracker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        decayTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        decayTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        manaTracker.topAnchor.constraint(equalTo: playerPanel.bottomAnchor, constant: 10).isActive = true
        manaTracker.leftAnchor.constraint(equalTo: decayTracker.rightAnchor, constant: 10).isActive = true
        manaTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        manaTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        growthTracker.topAnchor.constraint(equalTo: playerPanel.bottomAnchor, constant: 40).isActive = true
        growthTracker.leftAnchor.constraint(equalTo: manaTracker.rightAnchor, constant: 10).isActive = true
        growthTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        growthTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        animalTracker.topAnchor.constraint(equalTo: growthTracker.bottomAnchor, constant: 10).isActive = true
        animalTracker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        animalTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        animalTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        victoryTracker.topAnchor.constraint(equalTo: manaTracker.bottomAnchor, constant: 30).isActive = true
        victoryTracker.leftAnchor.constraint(equalTo: animalTracker.rightAnchor, constant: 10).isActive = true
        victoryTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        victoryTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        forestTracker.topAnchor.constraint(equalTo: decayTracker.bottomAnchor, constant: 10).isActive = true
        forestTracker.leftAnchor.constraint(equalTo: victoryTracker.rightAnchor, constant: 10).isActive = true
        forestTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        forestTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        skyTracker.topAnchor.constraint(equalTo: animalTracker.bottomAnchor, constant: 10).isActive = true
        skyTracker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        skyTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        skyTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        wildTracker.topAnchor.constraint(equalTo: forestTracker.bottomAnchor, constant: 10).isActive = true
        wildTracker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        wildTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        wildTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        trackersArray = [manaTracker, decayTracker, growthTracker, animalTracker, forestTracker, skyTracker, victoryTracker, wildTracker]
    }
    
    /// Configures the GameVC menu button
    private func layoutMenuButton() {
        let menuButton = KCFloatingActionButton()
        menuButton.setMenuButtonColor()
        menuButton.setPaddingY(viewHasAds: true)
        menuButton.items = []
        
        let settings = KCFloatingActionButtonItem()
        settings.setButtonOfType(.settings)
        settings.handler = { item in
            self.performSegue(withIdentifier: "showSettings", sender: nil)
        }
        
        let endTurn = KCFloatingActionButtonItem()
        endTurn.setButtonOfType(.endTurn)
        endTurn.handler = { item in
            if self.currentConnectionStatus != .notReachable {
                if self.currentPlayer == Player.instance.username {
                    self.endPlayerTurn()
                } else {
                    self.showAlert(.notYourTurn)
                }
            } else {
                self.showAlert(.noConnection)
            }
        }
        
        let quitGame = KCFloatingActionButtonItem()
        quitGame.setButtonOfType(.quitGame)
        quitGame.handler = { item in
            self.showAlert(.quitGame)
        }
        
        let endGame = KCFloatingActionButtonItem()
        endGame.setButtonOfType(.endGame)
        endGame.handler = { item in
            self.showAlert(.endGame)
        }
        
        menuButton.addItem(item: settings)
        menuButton.addItem(item: endTurn)
        guard let host = GameHandler.instance.game["username"] as? String else { return }
        if host == Player.instance.username {
            menuButton.addItem(item: endGame)
        } else {
            menuButton.addItem(item: quitGame)
        }
        
        view.addSubview(menuButton)
    }
    
    /// Configures banner ads, if premium hasn't been purchased
    private func layoutBannerAds() {
        if !PREMIUM_PURCHASED {
            //MARK: Initialize banner ads
            adBanner.adUnitID = "ca-app-pub-4384472824519738/9844119805"  //My ads
            //            adBanner.adUnitID = "ca-app-pub-3940256099942544/6300978111"    //Test ads
            adBanner.backgroundColor = .white
            adBanner.rootViewController = self
            adBanner.load(GADRequest())
            adBanner.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(adBanner)
            
            adBanner.heightAnchor.constraint(equalToConstant: 50).isActive = true
            adBanner.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            adBanner.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomLayoutConstant).isActive = true
        }
    }
}

//------------------------------------------
// MARK: - TableView DataSource and Delegate
//------------------------------------------
extension GameVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playersTableCell") as! PlayersTableCell
        cell.layoutCell(forPlayer: players[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 27.5
    }
}

//-----------------
// MARK: - Firebase
//-----------------
extension GameVC {
    /// Configures game of Firebase and begins observing
    private func setupGameAndObserve() {
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
                        GameHandler.instance.REF_GAME.removeAllObservers()
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
    
    /// Passes the current user's turn on Firebase
    /// - parameter userData: A Dictionary containing the user's data
    private func passTurn(withUserData userData: [String : AnyObject]) {
        var newPlayersArray = [[String : AnyObject]]()
        var playerToAppend = [String : AnyObject]()
        var newCurrentPlayer = [String : AnyObject]()
        
        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
        GameHandler.instance.REF_GAME.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == gameKey {
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [[String : AnyObject]] else { return }
                    
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
    
    /// Updates the current user's mana and VP turn statistics on Firebase
    /// - parameter mana: The Int value to compare to what's on Firebase
    /// - parameter victory: The Int value to compare to what's on Firebase
    private func updateFBUserStatistics(withMana mana: Int, andVictory victory: Int) {
        var userData = [String : AnyObject]()
        
        GameHandler.instance.REF_USER.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == FIRAuth.auth()?.currentUser?.uid {
                    if let firebaseUser = user.value as? [String : AnyObject] { userData = firebaseUser }
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
