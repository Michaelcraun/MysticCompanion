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
//    let player = Player()
    var victoryTaken = 0 {
        didSet {
            gameVPLabel.text = "Victory Point Pool: \(victoryTaken)/\(vpGoal)"
            if victoryTaken >= vpGoal {
                print("end of game")
                let endingPlayer = players[0]
                if let endingPlayerUsername = endingPlayer["username"] as? String {
                    self.endingPlayerUsername = endingPlayerUsername
                    if endingPlayerUsername == Player.instance.username {
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
        if isEndOfGameTurn { performSegue(withIdentifier: "showEndGame", sender: nil) }
        Player.instance.manaConstant = Int(manaTracker.constantStepper.value)
        Player.instance.decayConstant = Int(decayTracker.constantStepper.value)
        Player.instance.growthConstant = Int(growthTracker.constantStepper.value)
        Player.instance.animalConstant = Int(animalTracker.constantStepper.value)
        Player.instance.forestConstant = Int(forestTracker.constantStepper.value)
        Player.instance.skyConstant = Int(skyTracker.constantStepper.value)
        Player.instance.wildConstant = Int(wildTracker.constantStepper.value)
        Player.instance.currentVP = Int(victoryTracker.currentStepper.value) - Player.instance.boxVP
        
        let userData: Dictionary<String,AnyObject> = ["username" : Player.instance.username as AnyObject,
                                                      "deck" : Player.instance.deck?.rawValue as AnyObject,
                                                      "victoryPoints" : Player.instance.currentVP as AnyObject,
                                                      "boxVictory" : Player.instance.boxVP as AnyObject]
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEndGame" {
            if let destination = segue.destination as? EndGameVC {
                destination.game = game
            }
        }
    }
}
