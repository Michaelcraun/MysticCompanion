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
import Firebase
import FirebaseAuth
import MapKit
import StoreKit
import CoreData

class HomeVC: UIViewController, Alertable, Connection, NSFetchedResultsControllerDelegate {

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
    
    //MARK: Firebase Variables
    var currentUserID: String? = nil
    var userIsHostingGame = false
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
    
    //MARK: MapKit Variables
    var locationManager = CLLocationManager()
    
    //MARK: Data Variables
    let defaults = UserDefaults.standard
    let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
    var controller: NSFetchedResultsController<Game>!
    var coreDataGames = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserID = FIRAuth.auth()?.currentUser?.uid
        Player.instance.deck = .beastbrothers
        PREMIUM_PURCHASED = defaults.bool(forKey: "premium")
        coreDataHasBeenConverted = defaults.bool(forKey: "coreDataHasBeenConverted")
        
        askForRating()
        checkTheme()
        layoutView()
        locationManager.requestWhenInUseAuthorization()
        checkLocationAuthStatus()
        checkUsername(forKey: currentUserID)
        beginConnectionTest()
        
        if !coreDataHasBeenConverted {
            attemptGameFetch()
            if let objects = controller.fetchedObjects, objects.count > 0 { coreDataGames = objects }
            for game in coreDataGames {
                convertCoreDataGameIntoFirebaseEntry(forGame: game)
            }
            defaults.set(true, forKey: "coreDataHasBeenConverted")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Player.instance.hasQuitGame {
            GameHandler.instance.REF_GAME.removeAllObservers()
            Player.instance.reinitialize()
            reinitializeView()
        }
        
        currentUserID = FIRAuth.auth()?.currentUser?.uid
        Player.instance.deck = .beastbrothers
        
        checkTheme()
        layoutMenuButton()
        checkUsername(forKey: currentUserID)
        beginConnectionTest()
    }
    
    func setPlayerIcon(withDeck deck: DeckType) {
        Player.instance.deck = deck
        UIView.animate(withDuration: 0.5, animations: {
            self.playerIcon.alpha = 0
        }) { (success) in
            self.playerIcon.backgroundColor = deck.color
            self.playerIcon.addImage(deck.image, withWidthModifier: 20)
            UIView.animate(withDuration: 0.5, animations: {
                self.playerIcon.alpha = 1
            }, completion: nil)
        }
    }
    
    func joinGamePressed() {
        let userLocation = self.locationManager.location
        
        userIsHostingGame = false
        layoutGameLobby()
        nearbyGames = []
        observeGames(withUserLocation: userLocation!)
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
                switch winCondition {
                case "standard": destination.vpGoal += players.count * 5
                case "custom": destination.vpGoal = 13
                default: break
                }
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
            let error = error as NSError
            print("Error: \(error)")
        }
    }
}

