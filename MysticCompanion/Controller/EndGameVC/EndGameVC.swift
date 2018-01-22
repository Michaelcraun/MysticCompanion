//
//  EndGameVC.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import GoogleMobileAds
import KCFloatingActionButton
import GMStepper
import Firebase
import FirebaseAuth

class EndGameVC: UIViewController, Alertable, Connection {
    //MARK: Game Variables
    enum GameState {
        case vpNeeded
        case vpSubmitted
        case gameFinalized
    }
    var gameState: GameState = .vpNeeded {
        didSet {
            switch gameState {
            case .vpNeeded: shouldDisplayStepper = true
            case .vpSubmitted: shouldDisplayStepper = false
            case .gameFinalized: shouldDisplayStepper = false
            }
        }
    }
    
    //MARK: Firebase Variables
    var players = [Dictionary<String,AnyObject>]() {
        didSet {
            playersTable.animate()
        }
    }
    
    //MARK: UI Variables
    let playersTable = UITableView()
    let adBanner = GADBannerView()
    let menuButton = KCFloatingActionButton()
    var shouldDisplayStepper = true
    var winnersArray = [String]()
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        generateTestData()
        setupGameAndObserve()
        layoutView()
        beginConnectionTest()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showAlert(.endOfGame)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton(gameState: gameState)
        beginConnectionTest()
    }
    
    func donePressed() {
        let stepper = self.view.viewWithTag(4040) as! GMStepper
        let deckVP = Int(stepper.value)
        
        updateUser(Player.instance.username, withDeckVP: deckVP)
        playersTable.animate()
        layoutMenuButton(gameState: .vpSubmitted)
    }
    
    func quitPressed() {
        GameHandler.instance.REF_GAME.removeAllObservers()
        dismissPreviousViewControllers()
    }
}
