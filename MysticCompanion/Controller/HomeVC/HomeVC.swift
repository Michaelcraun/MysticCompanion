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
import MapKit

class HomeVC: UIViewController, Alertable {

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
    var nearbyGames = [Dictionary<String,AnyObject>]() {
        didSet {
            gameLobbyTable.reloadData()
        }
    }
    var players = [Dictionary<String,AnyObject>]() {
        didSet {
            gameLobbyTable.reloadData()
        }
    }
    
    //MARK: Game Variables
    var winCondition = ""
    
    //MARK: MapKit Variables
    var locationManager = CLLocationManager()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Convert CoreData game entries into Firebase entries?
        currentUserID = FIRAuth.auth()?.currentUser?.uid
        Player.instance.deck = .beastbrothers
        
        checkForRating()
        checkTheme()
        layoutView()
        locationManager.requestWhenInUseAuthorization()
        checkLocationAuthStatus()
        checkUsername(forKey: currentUserID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentUserID = FIRAuth.auth()?.currentUser?.uid
        checkTheme()
        layoutMenuButton()
        checkUsername(forKey: currentUserID)
        
        if Player.instance.hasQuitGame {
            Player.instance.reinitialize()
            gameLobby.fadeAlphaOut()
        }
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
        self.userIsHostingGame = false
        let userLoaction = self.locationManager.location
        self.layoutGameLobby()
        self.nearbyGames = []
        self.observeGames(withUserLocation: userLoaction!)
    }
    
    func checkForRating() {
        var timesAppOpened = defaults.integer(forKey: "timesAppOpened")
        let ratingLeft = defaults.bool(forKey: "ratingLeft")
        
        if timesAppOpened == 10 && !ratingLeft {
            //TODO: Show alert asking to leave rating
            
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
}

