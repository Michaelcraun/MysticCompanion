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

class EndGameVC: UIViewController {
    
    //MARK: Firebase Variables
    var game = Dictionary<String,AnyObject>()
    var players = [Dictionary<String,AnyObject>]() {
        didSet {
            playersTable.reloadData()
        }
    }
    
    //MARK: UI Variables
    let playersTable = UITableView()
    let adBanner = GADBannerView()
    let menuButton = KCFloatingActionButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutView()
        setupGameAndObserve()
    }
}
