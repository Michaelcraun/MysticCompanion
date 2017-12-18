//
//  SettingsVC.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import CoreData
import StoreKit
import KCFloatingActionButton

class SettingsVC: UIViewController {

    //MARK: UI Variables
    let backgroundImage = UIImageView()
    let currentVersion = UILabel()
    let upgradeDetails = UILabel()
    let bannerView = UIView()
    let previousGamesTable = UITableView()
    let menuButton = KCFloatingActionButton()
    
    //MARK: CoreData Variables
    var controller: NSFetchedResultsController<Game>!
    let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
    let defaults = UserDefaults.standard
    
    //MARK: StoreKit Variables
    var productPurchasing = SKProduct()
    var productList = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        attemptGameFetch()
        layoutView()
    }
    
    func setTheme(_ theme: SystemColor) {
        defaults.set(theme.rawValue, forKey: "theme")
        checkTheme()
        layoutSettingsButton()
        previousGamesTable.reloadData()
    }
}
