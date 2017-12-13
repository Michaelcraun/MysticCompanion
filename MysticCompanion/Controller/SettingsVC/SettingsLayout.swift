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

extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    func layoutView() {
        if PREMIUM_PURCHASED {
            layoutPreviousGamesTable()
        } else {
            layoutUpgradeLabels()
        }
        
        layoutBackgroundImage()
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
        
        currentVersion.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
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
        
        previousGamesTable.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        previousGamesTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        previousGamesTable.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        previousGamesTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func layoutSettingsButton() {
        settingsButton.buttonColor = .black
        settingsButton.paddingX = view.frame.width / 2 - settingsButton.frame.width / 2
        settingsButton.paddingY = 20
        
        let cancel = KCFloatingActionButtonItem()
        cancel.title = "Cancel"
        cancel.buttonColor = .white
        cancel.handler = { item in
            self.dismiss(animated: true, completion: nil)
        }
        
        let logout = KCFloatingActionButtonItem()
        logout.title = "Logout"
        logout.buttonColor = .white
        logout.handler = { item in
            do {
                try FIRAuth.auth()?.signOut()
                self.dismiss(animated: true, completion: nil)
            } catch (let error) {
                print(error)
            }
        }
        
        let purchase = KCFloatingActionButtonItem()
        purchase.title = "Purchase Premium"
        purchase.buttonColor = .white
        purchase.handler = { item in
            //TODO: Purchase premium version
        }
        
        let restore = KCFloatingActionButtonItem()
        restore.title = "Restore Premium"
        restore.buttonColor = .white
        restore.handler = { item in
            //TODO: Restore premium version
        }
        
        settingsButton.addItem(item: cancel)
        settingsButton.addItem(item: logout)
        settingsButton.addItem(item: purchase)
        settingsButton.addItem(item: restore)
        view.addSubview(settingsButton)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let games = controller.fetchedObjects, games.count > 0 {
            return games.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousGameCell") as! PreviousGameCell
        if let games = controller.fetchedObjects, games.count > 0 {
            cell.layoutGame(game: games[indexPath.row])
        } else {
            cell.layoutEmptyCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            if let games = self.controller.fetchedObjects, games.count > 0 {
                let game = games[indexPath.row]
                context.delete(game)
                ad.saveContext()
                self.attemptGameFetch()
                self.previousGamesTable.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { (action, index) in
            //TODO: Add Share Functionality
        }
        return [share, delete]
    }
}
