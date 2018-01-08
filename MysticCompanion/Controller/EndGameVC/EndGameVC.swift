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

class EndGameVC: UIViewController, Alertable {
    
    //MARK: Game Variables
    var gameState: GameState = .vpNeeded
    
    enum GameState {
        case vpNeeded
        case vpSubmitted
        case gameFinalized
    }
    
    //MARK: Firebase Variables
    var players = [Dictionary<String,AnyObject>]() {
        didSet {
            playersTable.reloadData()
        }
    }
    
    //MARK: UI Variables
    let playersTable = UITableView()
    let adBanner = GADBannerView()
    let menuButton = KCFloatingActionButton()
    var shouldDisplayStepper = true
    var winnersArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGameAndObserve()
        layoutView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showAlert(withTitle: "End of Game", andMessage: "The game has concluded. Please enter the amount of victory points contained in your deck.", andNotificationType: .endOfGame)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton(gameState: gameState)
    }
    
    func donePressed() {
        self.shouldDisplayStepper = false
        let stepper = self.view.viewWithTag(4040) as! GMStepper
        let deckVP = Int(stepper.value)
        self.updateUser(Player.instance.username, withDeckVP: deckVP)
        self.playersTable.reloadData()
        self.layoutMenuButton(gameState: .vpSubmitted)
    }
    
    func quitPressed() {
        guard let hostUsername = GameHandler.instance.game["username"] as? String else { return }
        
        if hostUsername == Player.instance.username {
            guard let currentUID = FIRAuth.auth()?.currentUser?.uid else { return }
            guard let playersArray = GameHandler.instance.game["players"] as? [Dictionary<String,AnyObject>] else { return }
            
            GameHandler.instance.clearCurrentGamesFromFirebaseDB(forKey: currentUID)
            GameHandler.instance.createFirebaseDBData(forGame: currentUID, withPlayers: playersArray, andWinners: winnersArray)
        }
        
        GameHandler.instance.REF_GAME.removeAllObservers()
        Player.instance.hasQuitGame = true
        dismissPreviousViewControllers()
    }
    
    func animateWinner(_ cell: UITableViewCell) {
        let winnerHeight = cell.frame.height / 2
        let winnerWidth = cell.frame.width
        
        let winnerImage = UIImageView()
        winnerImage.contentMode = .scaleAspectFit
        winnerImage.image = #imageLiteral(resourceName: "winner")
        winnerImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(winnerImage)
        
        winnerImage.heightAnchor.constraint(equalToConstant: winnerHeight).isActive = true
        winnerImage.widthAnchor.constraint(equalToConstant: winnerWidth).isActive = true
        winnerImage.rightAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        winnerImage.topAnchor.constraint(equalTo: cell.topAnchor, constant: cell.frame.height / 2 - winnerImage.frame.height / 2).isActive = true
        
        UIView.animate(withDuration: 0.5) {
            winnerImage.frame.origin.x += winnerWidth
        }
    }
}
