//
//  EndGameLayout.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/13/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import GoogleMobileAds
import KCFloatingActionButton

extension EndGameVC: UITableViewDataSource, UITableViewDelegate {
    func layoutView() {
        playersTable.dataSource = self
        playersTable.delegate = self
        playersTable.allowsSelection = false
        playersTable.register(EndGamePlayersCell.self, forCellReuseIdentifier: "endGamePlayersCell")
        playersTable.rowHeight = playersTable.frame.height / CGFloat(players.count)
        playersTable.separatorStyle = .none
        playersTable.backgroundColor = .orange
        playersTable.translatesAutoresizingMaskIntoConstraints = false
        
        
//        adBanner.adUnitID = "ca-app-pub-4384472824519738/9844119805"  //My ads
        adBanner.adUnitID = "ca-app-pub-3940256099942544/6300978111"    //Test ads
        adBanner.backgroundColor = .white
        adBanner.rootViewController = self
        adBanner.load(GADRequest())
        adBanner.translatesAutoresizingMaskIntoConstraints = false
        
        menuButton.buttonColor = .black
        menuButton.paddingX = view.frame.width / 2 - menuButton.frame.width / 2
        menuButton.setPaddingY()
        
        let settings = KCFloatingActionButtonItem()
        settings.buttonColor = .red
        settings.title = "Settings"
        settings.handler = { item in
            self.performSegue(withIdentifier: "showSettings", sender: nil)
        }
        
        let quit = KCFloatingActionButtonItem()
        quit.buttonColor = .white
        quit.title = "Quit"
        quit.handler = { item in
            //TODO: Handle exiting game
        }
        
        menuButton.addItem(item: settings)
        menuButton.addItem(item: quit)
        
        view.addSubview(playersTable)
        view.addSubview(menuButton)
        if !PREMIUM_PURCHASED { view.addSubview(adBanner) }
        
        var tableBottomBuffer: CGFloat {
            switch PREMIUM_PURCHASED {
            case true: return menuButton.frame.height + 30
            case false: return adBanner.frame.height + menuButton.frame.height + 40
            }
        }
        
        playersTable.topAnchor.constraint(equalTo: view.topAnchor, constant: UIDevice.current.topLayoutBuffer).isActive = true
        playersTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        playersTable.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        playersTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tableBottomBuffer).isActive = true
        
        if !PREMIUM_PURCHASED {
            adBanner.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            adBanner.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            adBanner.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            adBanner.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "endGamePlayersCell") as! EndGamePlayersCell
        //TODO: Configure cell
        cell.configureCell(forPlayer: players[indexPath.row])
        return cell
    }
}
