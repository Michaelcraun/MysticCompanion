//
//  GameVC.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import GMStepper

class GameVC: UIViewController, Alertable {
    
    //MARK: Game Variables
    let player = Player()
    var victoryTaken = 0 {
        didSet {
            gameVPLabel.text = "Victory Point Pool: \(victoryTaken)/\(vpGoal)"
            if victoryTaken >= vpGoal {
                print("end of game")
                let endingPlayer = players[0]
                if let endingPlayerUsername = endingPlayer["username"] as? String {
                    self.endingPlayerUsername = endingPlayerUsername
                    if endingPlayerUsername == player.username {
                        self.showAlert(withTitle: "End of Game", andMessage: "You ended the game. Please wait for the other players to complete their turns.")
                    } else {
                        if !isEndOfGameTurn {
                            self.showAlert(withTitle: "End of Game", andMessage: "\(endingPlayerUsername) ended the game. This will be your final turn.")
                            isEndOfGameTurn = true
                        }
                    }
                }
            }
        }
    }
    var vpGoal = 13
    var isEndOfGameTurn = false {
        didSet {
            print("isEndOfGameTurn: \(isEndOfGameTurn)")
        }
    }
    var username = ""
    var game = Dictionary<String,AnyObject>()
    var players = [Dictionary<String,AnyObject>]() {
        didSet {
            playersTable.reloadData()
        }
    }
    var playerIndex = 0
    var currentPlayer = ""
    var endingPlayerUsername = ""
    
    //MARK: UI Variables
    let playerPanel = UIView()
    let gameVPLabel = UILabel()
    let playersTable = UITableView()
    
    let manaTracker = TrackerView()
    let decayTracker = TrackerView()
    let growthTracker = TrackerView()
    let animalTracker = TrackerView()
    let forestTracker = TrackerView()
    let skyTracker = TrackerView()
    let victoryTracker = TrackerView()
    let wildTracker = TrackerView()
    
    var endTurnButton = UIButton()
    
    var trackersArray = [TrackerView]()
    var constantArray = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGameAndObserve()
        layoutView()
        setupPlayerTurn()
    }
    
    func setupPlayerTurn() {
        if isEndOfGameTurn {
            performSegue(withIdentifier: "showEndGame", sender: nil)
        } else {
            manaTracker.currentStepper.value = Double(player.manaConstant)
            manaTracker.constantStepper.value = Double(player.manaConstant)
            decayTracker.currentStepper.value = Double(player.decayConstant)
            decayTracker.constantStepper.value = Double(player.decayConstant)
            growthTracker.currentStepper.value = Double(player.growthConstant)
            growthTracker.constantStepper.value = Double(player.growthConstant)
            animalTracker.currentStepper.value = Double(player.animalConstant)
            animalTracker.constantStepper.value = Double(player.animalConstant)
            forestTracker.currentStepper.value = Double(player.forestConstant)
            forestTracker.constantStepper.value = Double(player.forestConstant)
            skyTracker.currentStepper.value = Double(player.skyConstant)
            skyTracker.constantStepper.value = Double(player.skyConstant)
            wildTracker.currentStepper.value = Double(player.wildConstant)
            wildTracker.constantStepper.value = Double(player.wildConstant)
            victoryTracker.currentStepper.value = Double(player.currentVP + player.boxVP)
            
            var delay: TimeInterval = 0.0
            for i in 0..<trackersArray.count {
                trackersArray[i].fadeAlphaWithDelayTo(1, withDuration: Double(trackersArray.count) * 0.1, andDelay: delay)
                delay += 0.1
            }
        }
    }
    
    func endPlayerTurn() {
        if isEndOfGameTurn { performSegue(withIdentifier: "showEndGame", sender: nil) }
        player.manaConstant = Int(manaTracker.constantStepper.value)
        player.decayConstant = Int(decayTracker.constantStepper.value)
        player.growthConstant = Int(growthTracker.constantStepper.value)
        player.animalConstant = Int(animalTracker.constantStepper.value)
        player.forestConstant = Int(forestTracker.constantStepper.value)
        player.skyConstant = Int(skyTracker.constantStepper.value)
        player.wildConstant = Int(wildTracker.constantStepper.value)
        player.currentVP = Int(victoryTracker.currentStepper.value) - player.boxVP
        
        let userData: Dictionary<String,AnyObject> = ["username" : player.username as AnyObject,
                                                      "deck" : player.deck?.rawValue as AnyObject,
                                                      "victoryPoints" : player.currentVP as AnyObject,
                                                      "boxVictory" : player.boxVP as AnyObject]
        updateFirebaseDBGame(withUserData: userData)
        
        var delay: TimeInterval = 0.0
        for i in 0..<trackersArray.count {
            trackersArray[i].fadeAlphaWithDelayTo(0, withDuration: Double(trackersArray.count) * 0.1, andDelay: delay)
            delay += 0.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(trackersArray.count) * 0.15) {
            self.setupPlayerTurn()
        }
    }
    
    func showEndOfGameAlert(withTitle title: String, andMessage message: String) {
        showAlert(withTitle: title, andMessage: message)
    }
}
