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

class EndGameVC: UIViewController {
    
    //MARK: Firebase Variables
//    var game = Dictionary<String,AnyObject>()
    //TODO: players is nil when VC is initialized... This is causing the NaN error
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
    }
    
    func donePressed() {
        self.shouldDisplayStepper = false
        let stepper = self.view.viewWithTag(4040) as! GMStepper
        let deckVP = Int(stepper.value)
        self.updateUsersVictoryPoints(forUser: Player.instance.username, withDeckVP: deckVP)
        //TODO: update victory label
        //TODO: remove stepper from cell
        //TODO: update firebase
        self.playersTable.reloadData()
    }
}
