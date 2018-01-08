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

class GameVC: UIViewController, Alertable {
    
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
    var endingPlayerUsername = ""
    
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
        didSet {
            playersTable.reloadData()
        }
    }
    
    var currentPlayer = "" {
        didSet {
            if currentPlayer == Player.instance.username && currentPlayer != endingPlayerUsername {
                showAlert(withTitle: "Your Turn", andMessage: "It is your turn. Please continue.", andNotificationType: .turnChange)
            }
        }
    }
    
    var userHasSpoiled = false {
        didSet {
            let userData: Dictionary<String,AnyObject> = ["username" : Player.instance.username as AnyObject,
                                                          "deck" : Player.instance.deck?.rawValue as AnyObject,
                                                          "finished" : false as AnyObject,
                                                          "victoryPoints" : Player.instance.currentVP as AnyObject,
                                                          "boxVictory" : Player.instance.boxVP as AnyObject]
            
            passTurn(withUserData: userData)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGameAndObserve()
        layoutView()
        setupPlayerTurn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton()
        
        if Player.instance.hasQuitGame {
            Player.instance.hasQuitGame = true
            dismissPreviousViewControllers()
        }
    }
    
    func setupPlayerTurn() {
        if isEndOfGameTurn {
            performSegue(withIdentifier: "showEndGame", sender: nil)
        } else {
            Player.instance.hasSpoiled = false
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
            
            var delay: TimeInterval = 0.0
            for i in 0..<trackersArray.count {
                trackersArray[i].fadeAlphaWithDelayTo(1, withDuration: Double(trackersArray.count) * 0.1, andDelay: delay)
                delay += 0.1
            }
        }
    }
    
    func endPlayerTurn() {
        if !Player.instance.hasSpoiled {
            Player.instance.manaConstant = Int(manaTracker.constantStepper.value)
            Player.instance.decayConstant = Int(decayTracker.constantStepper.value)
            Player.instance.growthConstant = Int(growthTracker.constantStepper.value)
            Player.instance.animalConstant = Int(animalTracker.constantStepper.value)
            Player.instance.forestConstant = Int(forestTracker.constantStepper.value)
            Player.instance.skyConstant = Int(skyTracker.constantStepper.value)
            Player.instance.wildConstant = Int(wildTracker.constantStepper.value)
            Player.instance.currentVP = Int(victoryTracker.currentStepper.value)
            
            let currentMana = Int(manaTracker.currentStepper.value)
            updateFBUserStatistics(withMana: currentMana)
        }
        
        let userData: Dictionary<String,AnyObject> = ["username" : Player.instance.username as AnyObject,
                                                      "deck" : Player.instance.deck?.rawValue as AnyObject,
                                                      "finished" : false as AnyObject,
                                                      "victoryPoints" : Player.instance.currentVP as AnyObject,
                                                      "boxVictory" : Player.instance.boxVP as AnyObject]
        passTurn(withUserData: userData)
        
        var delay: TimeInterval = 0.0
        for i in 0..<trackersArray.count {
            trackersArray[i].fadeAlphaWithDelayTo(0, withDuration: Double(trackersArray.count) * 0.1, andDelay: delay)
            delay += 0.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(trackersArray.count) * 0.15) {
            if self.isEndOfGameTurn && self.endingPlayerUsername != Player.instance.username {
                GameHandler.instance.REF_GAME.removeAllObservers()
                self.performSegue(withIdentifier: "showEndGame", sender: nil)
            } else {
                self.setupPlayerTurn()
            }
        }
    }
    
    @objc func checkForSpoil(sender: GMStepper) {
        let currentDecay = decayTracker.currentStepper.value
        let currentGrowth = growthTracker.currentStepper.value
        
        if currentDecay - 3 > currentGrowth && !Player.instance.hasSpoiled {
            showAlertWithOptions(withTitle: "Spoiled", andMessage: "According to the rules of the game, you've spoiled. Is this true? \nIf you tap Yes, you will gain no VP this turn and play will pass to the next player when you end your turn.", andNotificationType: .error)
            
            switch sender {
            case decayTracker.currentStepper: decayTracker.currentStepper.value -= 1
            case growthTracker.currentStepper: growthTracker.currentStepper.value += 1
            default: break
            }
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
                showVPAlert(withGame: GameHandler.instance.game)
            }
        }
    }
}
