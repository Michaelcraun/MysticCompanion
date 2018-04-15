//
//  SettingsVC.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import CoreData
import MessageUI
import StoreKit
import UIKit

import KCFloatingActionButton

import Firebase
import FirebaseAuth
import FirebaseDatabase

class SettingsVC: UIViewController, Connection {
    //MARK: - UI Variables
    let backgroundImage = UIImageView()
    let bannerView = UIView()
    let currentVersion = UILabel()
    let upgradeDetails = UILabel()
    let previousGamesTable = UITableView()
    let menuButton = KCFloatingActionButton()
    var purchaseButtonsAreEnabled = false
    
    //MARK: - Firebase Variables
    var currentUserID: String?
    var previousGames = [Dictionary<String,AnyObject>]() {
        willSet {
            previousGamesTable.animate()
        }
    }
    
    //MARK: - Data Variables
    let defaults = UserDefaults.standard
    
    //MARK: - StoreKit Variables
    var productPurchasing = SKProduct()
    var productList = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutView()
        beginConnectionTest()
        checkCanMakePayments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        observeDataForGamesPlayed()
    }
    
    /// Sets the users theme to the selected theme the user selected
    /// - parameter theme: The theme selected by the user
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

//---------------
// MARK: - Layout
//---------------
extension SettingsVC {
    /// The central point for layout on SettingsVC
    func layoutView() {
        setBackgroundImage(#imageLiteral(resourceName: "settingsBG"))
        layoutTopBanner()
        
        if PREMIUM_PURCHASED {
            layoutPreviousGamesTable()
        } else {
            layoutUpgradeLabels()
        }
        
        layoutSettingsButton()
    }
    
    /// Configures the top banner for SettingsVC
    func layoutTopBanner() {
        bannerView.backgroundColor = UIColor(red: 255 / 255, green: 81 / 255, blue: 72 / 255, alpha: 1)
        bannerView.anchorTo(view,
                            top: view.topAnchor,
                            leading: view.leadingAnchor,
                            trailing: view.trailingAnchor,
                            size: .init(width: 0, height: 50))
        
        let pageTitleLabel = UILabel()
        pageTitleLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 10)
        pageTitleLabel.text = "SETTINGS"
        pageTitleLabel.textAlignment = .center
        pageTitleLabel.anchorTo(bannerView,
                                bottom: bannerView.bottomAnchor,
                                leading: bannerView.leadingAnchor,
                                trailing: bannerView.trailingAnchor,
                                padding: .init(top: 0, left: 0, bottom: 5, right: 0))
    }
    
    /// Configures upgrade labels if user has not purchased premium
    func layoutUpgradeLabels() {
        currentVersion.font = UIFont(name: fontFamily, size: 15)
        currentVersion.numberOfLines = 0
        currentVersion.textAlignment = .center
        currentVersion.text = "You have not purchased the premium edition of MysticCompanion..."
        currentVersion.anchorTo(view,
                                top: bannerView.bottomAnchor,
                                leading: view.leadingAnchor,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 10, left: 20, bottom: 0, right: 20))
        
        upgradeDetails.font = UIFont(name: fontFamily, size: 15)
        upgradeDetails.numberOfLines = 0
        upgradeDetails.textAlignment = .center
        upgradeDetails.text = "After upgrading to the premium version, you'll be able to set a custom amount of victory points for your games and you'll be able to track your games. Please consider upgrading!"
        upgradeDetails.anchorTo(view,
                                top: currentVersion.bottomAnchor,
                                leading: view.leadingAnchor,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 10, left: 20, bottom: 0, right: 20))
    }
    
    /// Configures previous games table if user has purchased premium
    func layoutPreviousGamesTable() {
        previousGamesTable.dataSource = self
        previousGamesTable.delegate = self
        previousGamesTable.separatorStyle = .none
        previousGamesTable.backgroundColor = .clear
        previousGamesTable.allowsSelection = false
        previousGamesTable.register(PreviousGameCell.self, forCellReuseIdentifier: "previousGameCell")
        previousGamesTable.anchorTo(view,
                                    top: bannerView.bottomAnchor,
                                    bottom: view.bottomAnchor,
                                    leading: view.leadingAnchor,
                                    trailing: view.trailingAnchor,
                                    padding: .init(top: 10, left: 20, bottom: 20, right: 20))
    }
    
    /// Configures the menu button for SettingsVC
    func layoutSettingsButton() {
        menuButton.setMenuButtonColor()
        menuButton.paddingY = 20
        menuButton.items = []
        
        let cancel = KCFloatingActionButtonItem()
        cancel.setButtonOfType(.cancel)
        cancel.handler = { item in
            self.dismiss(animated: true, completion: nil)
        }
        
        let logout = KCFloatingActionButtonItem()
        logout.setButtonOfType(.logout)
        logout.handler = { item in
            self.logout()
        }
        
        let contactSupport = KCFloatingActionButtonItem()
        contactSupport.setButtonOfType(.contactSupport)
        contactSupport.handler = { item in
            if MFMailComposeViewController.canSendMail() {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                composeVC.setToRecipients(["support@craunicproductions.com"])
                composeVC.setSubject("MysticCompanion Support")
                
                self.present(composeVC, animated: true, completion: nil)
            } else {
                self.showAlert(.mailError)
            }
        }
        
        let changeTheme = KCFloatingActionButtonItem()
        changeTheme.setButtonOfType(.changeTheme)
        changeTheme.handler = { item in
            self.layoutThemeSelection()
        }
        
        let purchase = KCFloatingActionButtonItem()
        purchase.setButtonOfType(.purchase)
        purchase.handler = { item in
            if self.purchaseButtonsAreEnabled {
                self.shouldPresentLoadingView(true)
                self.buyProduct(productID: Products.premiumUpgrade.productIdentifier)
            } else {
                self.showAlert(.purchaseError)
            }
        }
        
        let restore = KCFloatingActionButtonItem()
        restore.setButtonOfType(.restore)
        restore.handler = { item in
            if self.purchaseButtonsAreEnabled {
                NetworkIndicator.networkOperationStarted()
                self.shouldPresentLoadingView(true)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().restoreCompletedTransactions()
            } else {
                self.showAlert(.purchaseError)
            }
        }
        
        menuButton.addItem(item: cancel)
        menuButton.addItem(item: logout)
        menuButton.addItem(item: contactSupport)
        menuButton.addItem(item: changeTheme)
        menuButton.addItem(item: purchase)
        menuButton.addItem(item: restore)
        menuButton.anchorTo(view)
    }
    
    /// Configures the theme selection view
    func layoutThemeSelection() {
        var blurEffectView = UIVisualEffectView()
        
        view.addBlurEffect()
        for subview in view.subviews {
            if subview.tag == 1001 {
                if let view = subview as? UIVisualEffectView {
                    blurEffectView = view
                }
            }
        }
        
        let themeSelector = KCFloatingActionButton()
        themeSelector.setPaddingY(viewHasAds: false)
        themeSelector.setMenuButtonColor()
        
        for theme in SystemColor.allThemes {
            let themeItem = KCFloatingActionButtonItem()
            themeItem.buttonColor = theme.color
            themeItem.title = theme.rawValue
            themeItem.handler = { item in
                self.setTheme(theme)
            }
            
            themeSelector.addItem(item: themeItem)
        }
        
        themeSelector.anchorTo(blurEffectView.contentView)
    }
}

//------------------------------------------
// MARK: - TableView DataSource and Delegate
//------------------------------------------
extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if previousGames.count > 0 {
            return previousGames.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousGameCell") as! PreviousGameCell
        if previousGames.count > 0 {
            let gameToDisplay = previousGames[indexPath.row]
            let playersArray = gameToDisplay["players"] as? [[String : AnyObject]] ?? []
            let winnersArray = gameToDisplay["winners"] as? [String] ?? []
            cell.layoutGame(withPlayers: playersArray, andWinners: winnersArray)
        } else {
            cell.layoutEmptyCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if previousGames.count > 0 {
            var cellHeight: CGFloat = 10
            let gameToDisplay = previousGames[indexPath.row]
            let playersArray = gameToDisplay["players"] as? [[String : AnyObject]] ?? []
            for _ in playersArray { cellHeight += 27.33 }
            return cellHeight
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "Share") { (action, index) in
            let gameToShare = self.previousGames[indexPath.row]
            guard let winners = gameToShare["winners"] as? [String] else { return }
            self.shareGame(withWinners: winners)
        }
        
        return [share]
    }
}

//----------------------
// MARK: - Mail Delegate
//----------------------
extension SettingsVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//-----------------
// MARK: - Firebase
//-----------------
extension SettingsVC {
    /// Observes the game directory for games the user has played
    func observeDataForGamesPlayed() {
        var gamesPlayed = [Dictionary<String,AnyObject>]()
        GameHandler.instance.REF_DATA.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dataSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for data in dataSnapshot {
                guard let dataPlayersArray = data.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                for player in dataPlayersArray {
                    guard let playerUsername = player["username"] as? String else { return }
                    if playerUsername == Player.instance.username {
                        guard let previousGame = data.value as? Dictionary<String,AnyObject> else { return }
                        gamesPlayed.append(previousGame)
                    }
                }
            }
            self.previousGames = gamesPlayed
        })
    }
    
    /// Logs the user out when logout button is pressed
    func logout() {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            dismiss(animated: true, completion: nil)
        } catch {
            showAlert(.firebaseLogout)
        }
    }
}

//-----------------
// MARK: - StoreKit
//-----------------
extension SettingsVC: Alertable, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    /// Begins the purchasing of a specific product
    /// - parameter productID: A String value containing the product identifier associated with the product being
    /// purchased
    func buyProduct(productID: String) {
        for product in productList {
            let productToCheck = product.productIdentifier
            if productToCheck == productID {
                productPurchasing = product
                
                NetworkIndicator.networkOperationStarted()
                
                let pay = SKPayment(product: productPurchasing)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(pay)
            }
        }
    }
    
    /// Checks if the user can make payments and displays an alert to the user if in-app purchases have been disabled
    func checkCanMakePayments() {
        if (SKPaymentQueue.canMakePayments()) {
            let productIDs: NSSet = NSSet(objects: Products.premiumUpgrade.productIdentifier)
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDs as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            showAlert(.iapDisabled)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        NetworkIndicator.networkOperationStarted()
        
        let myProducts = response.products
        for product in myProducts {
            productList.append(product)
        }
        
        purchaseButtonsAreEnabled = true
        NetworkIndicator.networkOperationFinished()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            let productID = t.payment.productIdentifier
            switch productID {
            case Products.premiumUpgrade.productIdentifier:
                let defaults = UserDefaults.standard
                PREMIUM_PURCHASED = true
                defaults.set(PREMIUM_PURCHASED, forKey: "premium")
                layoutView()
            default: break
            }
        }
        showAlert(.purchasesRestored)
        NetworkIndicator.networkOperationFinished()
        shouldPresentLoadingView(false)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        showAlert(.restoreFailed)
        NetworkIndicator.networkOperationFinished()
        shouldPresentLoadingView(false)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        NetworkIndicator.networkOperationStarted()
        
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            switch trans.transactionState {
            case .purchased:
                let productID = productPurchasing.productIdentifier
                switch productID {
                case Products.premiumUpgrade.productIdentifier:
                    let defaults = UserDefaults.standard
                    PREMIUM_PURCHASED = true
                    defaults.set(PREMIUM_PURCHASED, forKey: "premium")
                default: break
                }
                shouldPresentLoadingView(false)
                //                showAlert(.purchaseComplete)
                queue.finishTransaction(trans)
            case .failed:
                shouldPresentLoadingView(false)
                //                showAlert(.purchaseFailed)
                queue.finishTransaction(trans)
            default: break
            }
        }
        
        NetworkIndicator.networkOperationFinished()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        shouldPresentLoadingView(false)
    }
}
