//
//  ViewController.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/27/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import CoreData
import MapKit

import GMStepper
import KCFloatingActionButton

import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleMobileAds

class HomeVC: UIViewController, NSFetchedResultsControllerDelegate {
    //MARK: - UI Variables
    var needsInitialized = false
    let backgroundImage = UIImageView()
    let playerIcon = CircleView()
    let playerName = UILabel()
    let deckChoicesStackView = UIStackView()
    let beastbrothersIcon = CircleView()
    let dawnseekersIcon = CircleView()
    let lifewardensIcon = CircleView()
    let waveguardsIcon = CircleView()
    let menuButton = KCFloatingActionButton()
    let adBanner = GADBannerView()
    var gameLobby = UIView()
    let gameLobbyTable = UITableView()
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    //MARK: - Firebase Variables
    //MARK: - Data Variables
    var winCondition = ""
    var userIsHostingGame = false
    var gameShouldAutoStart = false
    var coreDataHasBeenConverted = false
    var nearbyGames = [[String : AnyObject]]() {
        willSet {
            gameLobbyTable.animate()
        }
    }
    
    var players = [[String : AnyObject]]() {
        willSet {
            gameLobbyTable.animate()
        }
    }
    
    let firManager = FirebaseManager()
    let locationManager = LocationManager()
    let skManager = StoreKitManager()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PREMIUM_PURCHASED = skManager.checkForPremium()
        layoutView()
        locationManager.manager.requestWhenInUseAuthorization()
        locationManager.checkLocationAuthStatus()
        beginConnectionTest()
        autoStartGame(userIsHosting: userIsHostingGame)
        skManager.askForRating()
        checkTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        firManager.delegate = self
        skManager.delegate = self
        
        if needsInitialized {
            GameHandler.instance.REF_GAME.removeAllObservers()
            Player.instance.reinitialize()
            reinitializeView()
        }
        
        if firManager.currentUserID == nil {
            gameLobby.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton()
        layoutBannerAds()
//        checkUsername(forKey: currentUserID)
        beginConnectionTest()
    }
    
    /// Sets the player's icon (at the top of the screen) with their selected deck type
    /// - parameter deck: The DeckType selected by the user
    func setPlayerIcon(withDeck deck: DeckType) {
        let deckIcons = [beastbrothersIcon, dawnseekersIcon, lifewardensIcon, waveguardsIcon]
        let deckTypes: [DeckType] = [.beastbrothers, .dawnseekers, .lifewardens, .waveguards]
        
        Player.instance.deck = deck
        UIView.animate(withDuration: 0.5, animations: {
            self.playerIcon.alpha = 0
            for icon in deckIcons {
                icon.alpha = 0
            }
        }) { (success) in
            self.playerIcon.backgroundColor = deck.color
            self.playerIcon.addImage(deck.image, withSize: 80)
            for i in 0..<deckTypes.count {
                if deckTypes[i] == deck {
                    deckIcons[i].backgroundColor = deckTypes[i].color
                } else {
                    deckIcons[i].backgroundColor = deckTypes[i].secondaryColor
                }
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                self.playerIcon.alpha = 1
                for icon in deckIcons {
                    icon.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    /// Displays the game lobby on load, if the user used one of the force touch menu icons
    /// - parameter userIsHosting: A Boolean value to determine whether the user is hosting or joining a game
    func autoStartGame(userIsHosting: Bool) {
        if gameShouldAutoStart {
            if userIsHosting {
                self.firManager.hostGame(withWinCondition: "standard", andVPGoal: 0)
//                self.hostGameAndObserve(withWinCondition: "standard", andVPGoal: 0)
            } else {
                self.joinGamePressed()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGame" {
            if let destination = segue.destination as? GameVC {
                slideInTransitioningDelegate.direction = .right
                slideInTransitioningDelegate.disableCompactHeight = false
                destination.transitioningDelegate = slideInTransitioningDelegate
                destination.modalPresentationStyle = .custom
            }
        } else if segue.identifier == "showFirebaseLogin" {
            if let destination = segue.destination as? SettingsVC {
                slideInTransitioningDelegate.direction = .bottom
                slideInTransitioningDelegate.disableCompactHeight = false
                destination.transitioningDelegate = slideInTransitioningDelegate
                destination.modalPresentationStyle = .custom
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: deckChoicesStackView) {
            let beastbrothersFrame = beastbrothersIcon.frame
            let dawnseekersFrame = dawnseekersIcon.frame
            let lifewardensFrame = lifewardensIcon.frame
            let waveguardsFrame = waveguardsIcon.frame
            
            if location.x >= beastbrothersFrame.minX && location.x <= beastbrothersFrame.maxX {
                if location.y >= beastbrothersFrame.minY && location.y <= beastbrothersFrame.maxY {
                    setPlayerIcon(withDeck: .beastbrothers)
                }
            } else if location.x >= dawnseekersFrame.minX && location.x <= dawnseekersFrame.maxX {
                if location.y >= dawnseekersFrame.minY && location.y <= dawnseekersFrame.maxY {
                    setPlayerIcon(withDeck: .dawnseekers)
                }
            } else if location.x >= lifewardensFrame.minX && location.x <= lifewardensFrame.maxX {
                if location.y >= lifewardensFrame.minY && location.y <= lifewardensFrame.maxY {
                    setPlayerIcon(withDeck: .lifewardens)
                }
            } else if location.x >= waveguardsFrame.minX && location.x <= waveguardsFrame.maxX {
                if location.y >= waveguardsFrame.minY && location.y <= waveguardsFrame.maxY {
                    setPlayerIcon(withDeck: .waveguards)
                }
            }
        }
    }
}

//---------------
// MARK: - Layout
//---------------
extension HomeVC {
    /// The central point for HomeVC layout
    private func layoutView() {
        setBackgroundImage(#imageLiteral(resourceName: "homeBG"))
        layoutPlayerIcon()
        layoutPlayerName()
        layoutDeckChoices()
        layoutMenuButton()
        layoutBannerAds()
        animateViewForStart()
    }
    
    /// Reinitializes HomeVC
    func reinitializeView() {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        layoutView()
        needsInitialized = false
    }
    
    /// Configures the player icon (the one at the top of the screen)
    private func layoutPlayerIcon() {
        playerIcon.backgroundColor = DeckType.beastbrothers.color
        playerIcon.addImage(DeckType.beastbrothers.image, withSize: 80)
        playerIcon.anchorTo(view,
                            top: view.topAnchor,
                            centerX: view.centerXAnchor,
                            padding: .init(top: topLayoutConstant, left: 0, bottom: 0, right: 0),
                            size: .init(width: 100, height: 100))
    }
    
    /// Configures the username label
    private func layoutPlayerName() {
        playerName.textColor = .darkText
        playerName.font = UIFont(name: "\(fontFamily)-Bold", size: 20)
        playerName.text = firManager.username
        playerName.anchorTo(view,
                            top: playerIcon.bottomAnchor,
                            centerX: view.centerXAnchor,
                            padding: .init(top: 20, left: 0, bottom: 0, right: 0))
    }
    
    /// Configures the stack view that contains the user's deck options
    private func layoutDeckChoices() {
        var previousDeck: DeckType {
            var deckType: DeckType = .beastbrothers
            if let _previousDeck = defaults.string(forKey: "previousDeck") {
                switch _previousDeck {
                case DeckType.beastbrothers.rawValue: deckType = .beastbrothers
                case DeckType.dawnseekers.rawValue: deckType = .dawnseekers
                case DeckType.lifewardens.rawValue: deckType = .lifewardens
                case DeckType.waveguards.rawValue: deckType = .waveguards
                default: deckType = .beastbrothers
                }
            }
            return deckType
        }
        
        beastbrothersIcon.alpha = 0
        beastbrothersIcon.backgroundColor = DeckType.beastbrothers.color
        beastbrothersIcon.addImage(DeckType.beastbrothers.image, withSize: 30)
        beastbrothersIcon.anchorTo(size: .init(width: 50, height: 50))
        
        dawnseekersIcon.alpha = 0
        dawnseekersIcon.backgroundColor = DeckType.dawnseekers.secondaryColor
        dawnseekersIcon.addImage(DeckType.dawnseekers.image, withSize: 30)
        dawnseekersIcon.anchorTo(size: .init(width: 50, height: 50))
        
        lifewardensIcon.alpha = 0
        lifewardensIcon.backgroundColor = DeckType.lifewardens.secondaryColor
        lifewardensIcon.addImage(DeckType.lifewardens.image, withSize: 30)
        lifewardensIcon.anchorTo(size: .init(width: 50, height: 50))
        
        waveguardsIcon.alpha = 0
        waveguardsIcon.backgroundColor = DeckType.waveguards.secondaryColor
        waveguardsIcon.addImage(DeckType.waveguards.image, withSize: 30)
        waveguardsIcon.anchorTo(size: .init(width: 50, height: 50))
        
        deckChoicesStackView.axis = UILayoutConstraintAxis.horizontal
        deckChoicesStackView.distribution = .equalSpacing
        deckChoicesStackView.alignment = .center
        deckChoicesStackView.spacing = 10
        deckChoicesStackView.addArrangedSubview(beastbrothersIcon)
        deckChoicesStackView.addArrangedSubview(dawnseekersIcon)
        deckChoicesStackView.addArrangedSubview(lifewardensIcon)
        deckChoicesStackView.addArrangedSubview(waveguardsIcon)
        deckChoicesStackView.anchorTo(view,
                                      top: playerName.bottomAnchor,
                                      centerX: view.centerXAnchor,
                                      padding: .init(top: 10, left: 0, bottom: 0, right: 0),
                                      size: .init(width: 230, height: 50))
        
        Player.instance.deck = previousDeck
        setPlayerIcon(withDeck: previousDeck)
    }
    
    /// Configures the menu button for the HomeVC
    private func layoutMenuButton() {
        menuButton.setMenuButtonColor()
        menuButton.setPaddingY(viewHasAds: !PREMIUM_PURCHASED)
        menuButton.items = []
        
        let startGame = KCFloatingActionButtonItem()
        startGame.setButtonOfType(.startGame)
        startGame.handler = { item in
            if self.currentConnectionStatus != .notReachable {
                if self.firManager.currentUserID == nil {
                    self.performSegue(withIdentifier: "showFirebaseLogin", sender: nil)
                } else {
                    self.layoutGameSetupView()
                }
            } else {
                self.showAlert(.noConnection)
            }
        }
        
        let joinGame = KCFloatingActionButtonItem()
        joinGame.setButtonOfType(.joinGame)
        joinGame.handler = { item in
            if self.currentConnectionStatus != .notReachable {
                if self.firManager.currentUserID == nil {
                    self.performSegue(withIdentifier: "showFirebaseLogin", sender: nil)
                } else {
                    self.joinGamePressed()
                }
            } else {
                self.showAlert(.noConnection)
            }
        }
        
        let settings = KCFloatingActionButtonItem()
        settings.setButtonOfType(.settings)
        settings.handler = { item in
            if self.firManager.currentUserID == nil {
                self.performSegue(withIdentifier: "showFirebaseLogin", sender: nil)
            } else {
                self.performSegue(withIdentifier: "showSettings", sender: nil)
            }
        }
        
        let statistics = KCFloatingActionButtonItem()
        statistics.setButtonOfType(.statistics)
        statistics.handler = { item in
            if self.firManager.currentUserID == nil {
                self.performSegue(withIdentifier: "showFirebaseLogin", sender: nil)
            } else {
                self.firManager.observeUserStatisticsForUser(self.firManager.username)
//                self.observeUserStatisticsForUser(Player.instance.username)
            }
        }
        
        menuButton.addItem(item: settings)
        menuButton.addItem(item: statistics)
        menuButton.addItem(item: startGame)
        menuButton.addItem(item: joinGame)
        menuButton.anchorTo(view)
    }
    
    /// Configures new view for game setup when user hosts a game
    private func layoutGameSetupView() {
        var blurEffectView = UIVisualEffectView()
        
        self.userIsHostingGame = true
        view.addBlurEffect()
        for subview in view.subviews {
            if subview.tag == 1001 {
                if let view = subview as? UIVisualEffectView {
                    blurEffectView = view
                }
            }
        }
        
        let vpSelector = KCFloatingActionButton()
        vpSelector.setMenuButtonColor()
        vpSelector.setPaddingY(viewHasAds: false)
        
        let cancel = KCFloatingActionButtonItem()
        cancel.setButtonOfType(.cancel)
        cancel.handler = { item in
            blurEffectView.fadeAlphaOut()
        }
        
        let standard = KCFloatingActionButtonItem()
        standard.setButtonOfType(.standardVP)
        standard.handler = { item in
            self.firManager.hostGame(withWinCondition: "standard", andVPGoal: 0)
//            self.hostGameAndObserve(withWinCondition: "standard", andVPGoal: 0)
            blurEffectView.fadeAlphaOut()
        }
        
        let custom = KCFloatingActionButtonItem()
        custom.setButtonOfType(.customVP)
        custom.handler = { item in
            if PREMIUM_PURCHASED {
                vpSelector.fadeAlphaOut()
                self.layoutCustomVPSelector()
            } else {
                self.showAlert(.unlockPremium)
            }
        }
        
        vpSelector.addItem(item: cancel)
        vpSelector.addItem(item: standard)
        vpSelector.addItem(item: custom)
        vpSelector.anchorTo(blurEffectView.contentView)
        
        blurEffectView.fadeAlphaTo(1, withDuration: 0.2)
    }
    
    /// Configures the victory point selector when user hosts a game
    private func layoutCustomVPSelector() {
        let vpStepper = GMStepper()
        vpStepper.buttonsBackgroundColor = theme.color
        vpStepper.labelBackgroundColor = theme.color1
        vpStepper.borderColor = theme.color
        vpStepper.borderWidth = 1
        vpStepper.labelFont = UIFont(name: fontFamily, size: 25)!
        vpStepper.value = 23
        vpStepper.maximumValue = 500
        vpStepper.translatesAutoresizingMaskIntoConstraints = false
        
        let menuButton = KCFloatingActionButton()
        menuButton.setPaddingY(viewHasAds: false)
        menuButton.setMenuButtonColor()
        
        let cancel = KCFloatingActionButtonItem()
        cancel.setButtonOfType(.cancel)
        cancel.handler = {item in
            vpStepper.fadeAlphaOut()
            menuButton.fadeAlphaOut()
            for subview in self.view.subviews {
                if subview.tag == 1000 {
                    subview.fadeAlphaOut()
                }
            }
        }
        
        let done = KCFloatingActionButtonItem()
        done.setButtonOfType(.done)
        done.handler = { item in
            let vpGoal = vpStepper.value
            self.firManager.hostGame(withWinCondition: "custom", andVPGoal: Int(vpGoal))
//            self.hostGameAndObserve(withWinCondition: "custom", andVPGoal: Int(vpGoal))
            vpStepper.fadeAlphaOut()
            menuButton.fadeAlphaOut()
            for subview in self.view.subviews {
                if subview.tag == 1000 {
                    subview.fadeAlphaOut()
                }
            }
        }
        
        menuButton.addItem(item: cancel)
        menuButton.addItem(item: done)
        menuButton.anchorTo(view)
        vpStepper.anchorTo(view,
                           centerX: view.centerXAnchor,
                           centerY: view.centerYAnchor,
                           size: .init(width: 150, height: 50))
    }
    
    /// Configures banner ads if the user hasn't purchased premium
    private func layoutBannerAds() {
        if PREMIUM_PURCHASED {
            adBanner.removeFromSuperview()
        } else {
            //MARK: Initialize banner ads
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
    
    /// Clears any games associated with the user's Firebase ID from Firebase and then begins searching for a new game
    /// that the user can join
    private func joinGamePressed() {
        GameHandler.instance.clearCurrentGamesFromFirebaseDB(forKey: firManager.currentUserID!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.userIsHostingGame = false
            self.layoutGameLobby()
            self.nearbyGames = []
            self.firManager.observeGames()
//            self.observeForNearbyGames()
        }
    }
    
    /// Configures the game lobby view and the associated table
    private func layoutGameLobby() {
        let gameLobbyBottomLayoutConstant = bottomLayoutConstant + adBuffer + 80
        
        gameLobby = UIView()
        gameLobby.backgroundColor = .clear
        gameLobby.clipsToBounds = true
        gameLobby.layer.cornerRadius = 15
        gameLobby.layer.borderColor = UIColor.black.cgColor
        gameLobby.layer.borderWidth = 2
        gameLobby.translatesAutoresizingMaskIntoConstraints = false
        
        gameLobbyTable.dataSource = self
        gameLobbyTable.delegate = self
        gameLobbyTable.separatorStyle = .none
        gameLobbyTable.backgroundColor = .clear
        gameLobbyTable.register(GameLobbyCell.self, forCellReuseIdentifier: "gameLobbyCell")
        gameLobbyTable.translatesAutoresizingMaskIntoConstraints = false
        
        gameLobby.addBlurEffect()
        gameLobby.anchorTo(view,
                           top: deckChoicesStackView.bottomAnchor,
                           bottom: view.bottomAnchor,
                           leading: view.leadingAnchor,
                           trailing: view.trailingAnchor,
                           padding: .init(top: 20, left: 20, bottom: gameLobbyBottomLayoutConstant, right: 20))
        gameLobbyTable.fillTo(gameLobby, padding: .init(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    /// Handles animating the view (slide in from left) when the app first loads and when the user quits the game
    private func animateViewForStart() {
        let screenWidth = UIScreen.main.bounds.width
        view.frame.origin.x += screenWidth
        
        UIView.animate(withDuration: 0.2) {
            self.view.frame.origin.x -= screenWidth
        }
    }
}

//------------------------------------------
// MARK: - TableView DataSource and Delegate
//------------------------------------------
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userIsHostingGame {
            switch players.count {
            case 1: return players.count + 1
            case 2...3: return players.count + 2
            case 4: return players.count + 1
            default: return 0
            }
        } else {
            return nearbyGames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameLobbyCell", for: indexPath) as! GameLobbyCell
        if userIsHostingGame {
            if players.count > 0 && players.count < 2 {
                switch indexPath.row {
                case 0: cell.layoutWaitingCell(withMessage: "Waiting for players...")
                default: cell.layoutCellForHost(withUser: players[indexPath.row - 1])
                }
            } else if players.count > 1 && players.count < 4 {
                switch indexPath.row {
                case 0: cell.layoutWaitingCell(withMessage: "Waiting for players...")
                case players.count + 1: cell.layoutStartGameCell()
                default: cell.layoutCellForHost(withUser: players[indexPath.row - 1])
                }
            } else {
                switch indexPath.row {
                case 4: cell.layoutStartGameCell()
                default: cell.layoutCellForHost(withUser: players[indexPath.row])
                }
            }
        } else {
            if nearbyGames.count == 0 {
                cell.layoutWaitingCell(withMessage: "Waiting for games...")
            } else {
                cell.layoutCellForGuest(withGame: nearbyGames[indexPath.row])
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if userIsHostingGame {
            var startGameIndex: Int {
                switch players.count {
                case 2: return 3
                case 3: return 4
                case 4: return 4
                default: return 0
                }
            }
            if indexPath.row == startGameIndex {
                GameHandler.instance.updateFirebaseDBGame(key: firManager.currentUserID!, gameData: ["gameStarted" : true])
                performSegue(withIdentifier: "startGame", sender: nil)
            } else {
                guard let cell = tableView.cellForRow(at: indexPath) as? GameLobbyCell else { return }
                let user = cell.user
                let username = user["username"] as? String ?? ""
                self.firManager.observeUserStatisticsForUser(username)
//                self.observeUserStatisticsForUser(username)
            }
        } else {
            guard let cell = tableView.cellForRow(at: indexPath) as? GameLobbyCell else { return }
            if let username = cell.user["username"] as? String {
                self.firManager.observeUserStatisticsForUser(username)
//                self.observeUserStatisticsForUser(username)
            } else {
                let userData: [String : Any] = ["username" :                firManager.username,
                                                      "deck" :              Player.instance.deck.rawValue,
                                                      "finished" :          false,
                                                      "victoryPoints" :     0,
                                                      "userHasQuitGame" :   false,
                                                      "boxVictory" :        0]
                GameHandler.instance.game = nearbyGames[indexPath.row]
                firManager.joinGame(withUserData: userData)
//                updateGame(withUserData: userData)
//                observeGameForStart()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
