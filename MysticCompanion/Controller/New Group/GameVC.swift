//
//  GameVC.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import GMStepper
import GoogleMobileAds

class GameVC: UIViewController, Alertable, Connection {
    
    //MARK: UI Variables
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

    //MARK: Game Variables
    var isEndOfGameTurn = false
    var userHasQuitGame = false
    var userHasSpoiled = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        generateTestData()
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
    
    func setupPlayerTurn() {
        if isEndOfGameTurn {
            performSegue(withIdentifier: "showEndGame", sender: nil)
        }
    
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
        victoryTracker.currentStepper.value = Double(Player.instance.currentVP + Player.instance.boxVP)
        
        currentVP = Int(victoryTracker.currentStepper.value) + Player.instance.boxVP
        
        var delay: TimeInterval = 0.0
        for i in 0..<trackersArray.count {
            trackersArray[i].fadeAlphaWithDelayTo(1, withDuration: Double(trackersArray.count) * 0.1, andDelay: delay)
            delay += 0.1
        }
    }
    
    func endPlayerTurn() {
        if !userHasSpoiled {
            Player.instance.manaConstant = Int(manaTracker.constantStepper.value)
            Player.instance.decayConstant = Int(decayTracker.constantStepper.value)
            Player.instance.growthConstant = Int(growthTracker.constantStepper.value)
            Player.instance.animalConstant = Int(animalTracker.constantStepper.value)
            Player.instance.forestConstant = Int(forestTracker.constantStepper.value)
            Player.instance.skyConstant = Int(skyTracker.constantStepper.value)
            Player.instance.wildConstant = Int(wildTracker.constantStepper.value)
            Player.instance.currentVP = Int(victoryTracker.currentStepper.value)
            
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
    
    func animateTrackersOut() {
        //MARK: Fades out all trackers, one by one, at the end of the user's turn and then either sets up
        //the view for the user's next turn or segues to EndGameVC (if this is the user's last turn.
        var delay: TimeInterval = 0.0
        for i in 0..<trackersArray.count {
            trackersArray[i].fadeAlphaWithDelayTo(0, withDuration: Double(trackersArray.count) * 0.1, andDelay: delay)
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
    
    @objc func checkForSpoil(sender: GMStepper) {
        let currentDecay = decayTracker.currentStepper.value
        let currentGrowth = growthTracker.currentStepper.value
        
        if currentDecay - 3 > currentGrowth && !userHasSpoiled {
            showAlert(.spoil)
        }
        sender.reset()
    }
    
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
    
    func saveUserDeck() {
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
