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

class EndGameVC: UIViewController, Alertable {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGameAndObserve()
        layoutView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAlert(withTitle: "End of Game", andMessage: "The game has concluded. Please enter the amount of victory points contained in your deck.", andNotificationType: .endOfGame)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton()
    }
    
    func donePressed() {
        self.shouldDisplayStepper = false
        let stepper = self.view.viewWithTag(4040) as! GMStepper
        let deckVP = Int(stepper.value)
        self.updateUser(Player.instance.username, withDeckVP: deckVP)
        self.playersTable.reloadData()
    }
    
    func quitPressed() {
        GameHandler.instance.REF_GAME.removeAllObservers()
        
        let gameVC = GameVC()
        gameVC.userQuitGame = true
        dismiss(animated: true, completion: nil)
    }
}
