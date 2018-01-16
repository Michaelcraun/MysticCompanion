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

class SettingsVC: UIViewController, Connection {

    //MARK: UI Variables
    let backgroundImage = UIImageView()
    let currentVersion = UILabel()
    let upgradeDetails = UILabel()
    let bannerView = UIView()
    let previousGamesTable = UITableView()
    let menuButton = KCFloatingActionButton()
    var purchaseButtonsAreEnabled = false
    
    //MARK: Firebase Variables
    var currentUserID: String?
    var previousGames = [Dictionary<String,AnyObject>]() {
        willSet {
            previousGamesTable.animate()
        }
    }
    
    //MARK: Data Variables
    let defaults = UserDefaults.standard
    
    //MARK: StoreKit Variables
    var productPurchasing = SKProduct()
    var productList = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeDataForGamesPlayed()
        layoutView()
        beginConnectionTest()
        checkCanMakePayments()
    }
    
    func setTheme(_ theme: SystemColor) {
        for subview in view.subviews {
            if subview.tag == 1001 {
                if let view = subview as? UIVisualEffectView {
                    view.fadeAlphaOut()
                }
            }
        }
        
        defaults.set(theme.rawValue, forKey: "theme")
        checkTheme()
        layoutSettingsButton()
    }
}
