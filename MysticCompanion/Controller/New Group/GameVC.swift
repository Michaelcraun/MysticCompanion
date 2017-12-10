//
//  GameVC.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import GMStepper

class GameVC: UIViewController {
    
    //MARK: Game Variables
    let player = Player()
    var game = Dictionary<String,AnyObject>()
    var players = [Dictionary<String,AnyObject>]() {
        didSet {
            playersTable.reloadData()
        }
    }
    
    //MARK: UI Variables
    let playerPanel = UIView()
    let currentPlayerLabel = UILabel()
    let currentPlayerVPLabel = UILabel()
    
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

        layoutView()
        setupPlayerTurn()
    }
    
    func setupPlayerTurn() {
        var delay: TimeInterval = 0.0
        for i in 0..<trackersArray.count {
            print(constantArray[i])
            trackersArray[i].currentStepper.value = Double(constantArray[i])
            if trackersArray[i] != victoryTracker { trackersArray[i].constantStepper.value = Double(constantArray[i]) }
            trackersArray[i].fadeAlphaWithDelayTo(1, withDuration: Double(trackersArray.count) * 0.1, andDelay: delay)
            delay += 0.1
        }
    }
    
    @objc func endPlayerTurn(sender: UIButton!) {
        player.manaConstant = Int(manaTracker.constantStepper.value)
        player.decayConstant = Int(decayTracker.constantStepper.value)
        player.growthConstant = Int(growthTracker.constantStepper.value)
        player.animalConstant = Int(animalTracker.constantStepper.value)
        player.forestConstant = Int(forestTracker.constantStepper.value)
        player.skyConstant = Int(skyTracker.constantStepper.value)
        player.wildConstant = Int(wildTracker.constantStepper.value)
        
        var delay: TimeInterval = 0.0
        for i in 0..<trackersArray.count {
            trackersArray[i].currentStepper.value = Double(constantArray[i])
            if trackersArray[i] != victoryTracker { trackersArray[i].constantStepper.value = Double(constantArray[i]) }
            trackersArray[i].fadeAlphaWithDelayTo(0, withDuration: Double(trackersArray.count) * 0.1, andDelay: delay)
            delay += 0.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(trackersArray.count) * 0.15) {
            self.setupPlayerTurn()
        }
        print(player)
    }
}
