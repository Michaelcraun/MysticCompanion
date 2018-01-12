//
//  SettingsLayout.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import KCFloatingActionButton
import Firebase
import StoreKit
import MessageUI

extension SettingsVC: UITableViewDataSource, MFMailComposeViewControllerDelegate, UITableViewDelegate {
    func layoutView() {
        layoutBackgroundImage()
        layoutTopBanner()
        
        if PREMIUM_PURCHASED {
            layoutPreviousGamesTable()
        } else {
            layoutUpgradeLabels()
        }
        
        layoutSettingsButton()
    }
    
    func layoutBackgroundImage() {
        backgroundImage.image = #imageLiteral(resourceName: "settingsBG")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.alpha = 0.5
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImage)
        
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func layoutTopBanner() {
        bannerView.backgroundColor = UIColor(red: 255 / 255, green: 81 / 255, blue: 72 / 255, alpha: 1)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        let pageTitleLabel = UILabel()
        pageTitleLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 10)
        pageTitleLabel.text = "SETTINGS"
        pageTitleLabel.textAlignment = .center
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bannerView)
        bannerView.addSubview(pageTitleLabel)
        
        bannerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bannerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bannerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        pageTitleLabel.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -5).isActive = true
        pageTitleLabel.leftAnchor.constraint(equalTo: bannerView.leftAnchor).isActive = true
        pageTitleLabel.rightAnchor.constraint(equalTo: bannerView.rightAnchor).isActive = true
    }
    
    func layoutUpgradeLabels() {
        currentVersion.font = UIFont(name: fontFamily, size: 15)
        currentVersion.numberOfLines = 0
        currentVersion.textAlignment = .center
        currentVersion.text = "You have not purchased the premium edition of MysticCompanion..."
        currentVersion.translatesAutoresizingMaskIntoConstraints = false
        
        upgradeDetails.font = UIFont(name: fontFamily, size: 15)
        upgradeDetails.numberOfLines = 0
        upgradeDetails.textAlignment = .center
        upgradeDetails.text = "After upgrading to the premium version, you'll be able to set a custom amount of victory points for your games and you'll be able to track your games. Please consider upgrading!"
        upgradeDetails.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(currentVersion)
        view.addSubview(upgradeDetails)
        
        currentVersion.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 10).isActive = true
        currentVersion.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        currentVersion.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        upgradeDetails.topAnchor.constraint(equalTo: currentVersion.bottomAnchor, constant: 10).isActive = true
        upgradeDetails.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        upgradeDetails.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    }
    
    func layoutPreviousGamesTable() {
        previousGamesTable.dataSource = self
        previousGamesTable.delegate = self
        previousGamesTable.separatorStyle = .none
        previousGamesTable.backgroundColor = .clear
        previousGamesTable.register(PreviousGameCell.self, forCellReuseIdentifier: "previousGameCell")
        previousGamesTable.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(previousGamesTable)
        
        previousGamesTable.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 10).isActive = true
        previousGamesTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        previousGamesTable.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        previousGamesTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }
    
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
                composeVC.setToRecipients(["vapemeistersupport@craunicproductions.com"])
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
            //TODO: Purchase premium version
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
            //TODO: Restore premium version
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
        view.addSubview(menuButton)
    }
    
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
        themeSelector.setPaddingY()
        themeSelector.setMenuButtonColor()
        
        let drabGray = KCFloatingActionButtonItem()
        drabGray.setButtonOfType(.drabGray)
        drabGray.handler = { item in
            self.setTheme(.drabGray)
            blurEffectView.fadeAlphaOut()
        }
        
        let pastelBlue = KCFloatingActionButtonItem()
        pastelBlue.setButtonOfType(.pastelBlue)
        pastelBlue.handler = { item in
            self.setTheme(.pastelBlue)
            blurEffectView.fadeAlphaOut()
        }
        
        let pastelGreen = KCFloatingActionButtonItem()
        pastelGreen.setButtonOfType(.pastelGreen)
        pastelGreen.handler = { item in
            self.setTheme(.pastelGreen)
            blurEffectView.fadeAlphaOut()
        }
        
        let pastelPurple = KCFloatingActionButtonItem()
        pastelPurple.setButtonOfType(.pastelPurple)
        pastelPurple.handler = { item in
            self.setTheme(.pastelPurple)
            blurEffectView.fadeAlphaOut()
        }
        
        let pastelYellow = KCFloatingActionButtonItem()
        pastelYellow.setButtonOfType(.pastelYellow)
        pastelYellow.handler = { item in
            self.setTheme(.pastelYellow)
            blurEffectView.fadeAlphaOut()
        }
        
        themeSelector.addItem(item: drabGray)
        themeSelector.addItem(item: pastelBlue)
        themeSelector.addItem(item: pastelGreen)
        themeSelector.addItem(item: pastelPurple)
        themeSelector.addItem(item: pastelYellow)
        
        blurEffectView.contentView.addSubview(themeSelector)
    }
    
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
            cell.layoutGame(game: previousGames[indexPath.row])
        } else {
            cell.layoutEmptyCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "Share") { (action, index) in
            //TODO: Add Share Functionality
        }
        
        return [share]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: Segue to GameDetailsVC
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if previousGames.count > 0 {
            var cellHeight: CGFloat = 0
            if let playersArray = previousGames[indexPath.row]["players"] as? [Dictionary<String,AnyObject>] {
                cellHeight = CGFloat(playersArray.count) * 27.33 + CGFloat((playersArray.count) * 5)
            }
            return cellHeight
        } else {
            return UITableViewAutomaticDimension
        }
    }
}
