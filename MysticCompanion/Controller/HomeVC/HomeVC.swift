//
//  ViewController.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/27/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import KCFloatingActionButton
import GoogleMobileAds
import MapKit

import Firebase
import FirebaseAuth
import StoreKit
import CoreData

class HomeVC: UIViewController, Alertable, Connection, NSFetchedResultsControllerDelegate {
    //MARK: UI Variables
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
    
    //MARK: Firebase Variables
    var currentUserID: String? = nil
    var userIsHostingGame = false
    var gameShouldAutoStart = false
    var coreDataHasBeenConverted = false
    var nearbyGames = [Dictionary<String,AnyObject>]() {
        willSet {
            gameLobbyTable.animate()
        }
    }
    var players = [Dictionary<String,AnyObject>]() {
        willSet {
            gameLobbyTable.animate()
        }
    }
    
    //MARK: Game Variables
    var winCondition = ""
    var locationManager = CLLocationManager()
    
    //MARK: Data Variables
    let defaults = UserDefaults.standard
    let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
    var controller: NSFetchedResultsController<Game>!
    var coreDataGames = [Game]()
    
    override func viewDidLoad() {
        print("HOME: viewDidLoad()")
        super.viewDidLoad()
        currentUserID = FIRAuth.auth()?.currentUser?.uid
        PREMIUM_PURCHASED = defaults.bool(forKey: "premium")
        
        layoutView()
        locationManager.requestWhenInUseAuthorization()
        checkLocationAuthStatus()
        checkUsername(forKey: currentUserID)
        beginConnectionTest()
        convertCoreDataGamesIntoFirebaseEntries()
        autoStartGame(userIsHosting: userIsHostingGame)
        askForRating()
        checkTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if needsInitialized {
            GameHandler.instance.REF_GAME.removeAllObservers()
            Player.instance.reinitialize()
            reinitializeView()
        }
        
        currentUserID = FIRAuth.auth()?.currentUser?.uid
        if currentUserID == nil {
            gameLobby.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton()
        layoutBannerAds()
        checkUsername(forKey: currentUserID)
        beginConnectionTest()
    }
    
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
            self.playerIcon.addImage(deck.image, withWidthModifier: 20)
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
    
    func autoStartGame(userIsHosting: Bool) {
        if gameShouldAutoStart {
            if userIsHosting {
                self.hostGameAndObserve(withWinCondition: "standard", andVPGoal: 0)
            } else {
                self.joinGamePressed()
            }
        }
    }
    
    func joinGamePressed() {
        GameHandler.instance.clearCurrentGamesFromFirebaseDB(forKey: currentUserID!)
        userIsHostingGame = false
        layoutGameLobby()
        nearbyGames = []
        observeForNearbyGames()
    }
    
    func askForRating() {
        var timesAppOpened = defaults.integer(forKey: "timesAppOpened")
        
        if timesAppOpened >= 10 {
            SKStoreReviewController.requestReview()
            timesAppOpened = 0
        } else {
            timesAppOpened += 1
        }
        
        defaults.set(timesAppOpened, forKey: "timesAppOpened")
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
    
    func attemptGameFetch() {
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [dateSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        self.controller = controller
        do {
            try controller.performFetch()
        } catch {
            showAlert(.coreDataError)
        }
    }
}

