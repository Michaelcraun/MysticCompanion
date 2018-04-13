//
//  EndGameLayout.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/13/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import KCFloatingActionButton
import GMStepper
import GoogleMobileAds

extension EndGameVC {
    func layoutView() {
        layoutBackground()
        layoutPlayersTable()
        layoutMenuButton(gameState: gameState)
        layoutAds()
    }
    
    func layoutBackground() {
        let backgroundImage = UIImageView()
        backgroundImage.image = #imageLiteral(resourceName: "endGameBG")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.alpha = 0.5
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImage)
        
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func layoutPlayersTable() {
        playersTable.dataSource = self
        playersTable.delegate = self
        playersTable.allowsSelection = false
        playersTable.register(EndGamePlayersCell.self, forCellReuseIdentifier: "endGamePlayersCell")
        playersTable.separatorStyle = .none
        playersTable.backgroundColor = .clear
        playersTable.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playersTable)
        
        var tableBottomBuffer: CGFloat {
            switch PREMIUM_PURCHASED {
            case true: return menuButton.frame.height + 30
            case false: return adBanner.frame.height + menuButton.frame.height + 40
            }
        }
        
        playersTable.topAnchor.constraint(equalTo: view.topAnchor, constant: topLayoutConstant).isActive = true
        playersTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        playersTable.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        playersTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tableBottomBuffer).isActive = true
        
        playersTable.animate()
    }
    
    func layoutMenuButton(gameState: GameState) {
        self.gameState = gameState
        
        menuButton.setMenuButtonColor()
        menuButton.setPaddingY(viewHasAds: true)
        menuButton.items = []
        
        let settings = KCFloatingActionButtonItem()
        settings.setButtonOfType(.settings)
        settings.handler = { item in
            self.performSegue(withIdentifier: "showSettings", sender: nil)
        }
        
        let done = KCFloatingActionButtonItem()
        done.setButtonOfType(.done)
        done.handler = { item in
            self.donePressed()
        }
        
        let quit = KCFloatingActionButtonItem()
        quit.setButtonOfType(.quitGame)
        quit.handler = { item in
            self.quitPressed()
        }
        
        let share = KCFloatingActionButtonItem()
        share.setButtonOfType(.share)
        share.handler = { item in
            self.shareGame(withWinners: self.winnersArray)
        }
        
        menuButton.addItem(item: settings)
        if gameState == .vpNeeded {
            menuButton.addItem(item: done)
        } else if gameState == .gameFinalized {
            menuButton.addItem(item: quit)
            menuButton.addItem(item: share)
        }
        
        view.addSubview(menuButton)
    }
    
    func layoutAds() {
        if !PREMIUM_PURCHASED {
            adBanner.adUnitID = "ca-app-pub-4384472824519738/9844119805"  //My ads
//            adBanner.adUnitID = "ca-app-pub-3940256099942544/6300978111"    //Test ads
            adBanner.backgroundColor = .white
            adBanner.rootViewController = self
            adBanner.load(GADRequest())
            adBanner.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(adBanner)
            
            adBanner.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomLayoutConstant).isActive = true
            adBanner.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            adBanner.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            adBanner.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
}

extension EndGameVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "endGamePlayersCell") as! EndGamePlayersCell
        cell.configureCell(forPlayer: players[indexPath.row], shouldDisplayStepper: shouldDisplayStepper, withWinners: winnersArray)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return playersTable.frame.height / CGFloat(players.count)
    }
}
