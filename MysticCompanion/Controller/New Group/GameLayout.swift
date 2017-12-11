//
//  GameLayout.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/8/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import GMStepper

extension GameVC: UITableViewDataSource, UITableViewDelegate {
    func layoutView() {
        layoutBackground()
        layoutPlayersPanel()
        layoutTrackers()
        layoutEndTurnButton()
    }
    
    func layoutBackground() {
        let backgroundImage = UIImageView()
        backgroundImage.image = #imageLiteral(resourceName: "gameBG")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.alpha = 0.5
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImage)
        
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func layoutPlayersPanel() {
        let panelHeight = CGFloat(players.count) * 27.5 + 16.5
        
        playerPanel.layer.cornerRadius = 10
        playerPanel.layer.borderColor = UIColor.black.cgColor
        playerPanel.layer.borderWidth = 2
        playerPanel.backgroundColor = primaryColor
        playerPanel.clipsToBounds = true
        playerPanel.translatesAutoresizingMaskIntoConstraints = false
        
        gameVPLabel.font = UIFont(name: fontFamily, size: 10)
        gameVPLabel.textAlignment = .center
        gameVPLabel.text = "Victory Point Pool: 0/23"
        gameVPLabel.translatesAutoresizingMaskIntoConstraints = false
        
        playersTable.allowsSelection = false
        playersTable.dataSource = self
        playersTable.delegate = self
        playersTable.register(PlayersTableCell.self, forCellReuseIdentifier: "playersTableCell")
        playersTable.rowHeight = 27.5
        playersTable.separatorStyle = .none
        playersTable.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playerPanel)
        playerPanel.addSubview(gameVPLabel)
        playerPanel.addSubview(playersTable)
        
        playerPanel.topAnchor.constraint(equalTo: view.topAnchor, constant: UIDevice.current.topLayoutBuffer).isActive = true
        playerPanel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        playerPanel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        playerPanel.heightAnchor.constraint(equalToConstant: panelHeight).isActive = true
        
        gameVPLabel.topAnchor.constraint(equalTo: playerPanel.topAnchor, constant: 5).isActive = true
        gameVPLabel.leftAnchor.constraint(equalTo: playerPanel.leftAnchor).isActive = true
        gameVPLabel.rightAnchor.constraint(equalTo: playerPanel.rightAnchor).isActive = true
        
        playersTable.topAnchor.constraint(equalTo: gameVPLabel.bottomAnchor).isActive = true
        playersTable.leftAnchor.constraint(equalTo: playerPanel.leftAnchor).isActive = true
        playersTable.rightAnchor.constraint(equalTo: playerPanel.rightAnchor).isActive = true
        playersTable.bottomAnchor.constraint(equalTo: playerPanel.bottomAnchor).isActive = true
    }
    
    func layoutTrackers() {
        let screenWidth = view.frame.width
        let trackerWidth = (screenWidth - 40) / 3
        
        manaTracker.initTrackerOfType(.mana)
        manaTracker.alpha = 0
        manaTracker.translatesAutoresizingMaskIntoConstraints = false
        
        decayTracker.initTrackerOfType(.decay)
        decayTracker.alpha = 0
        decayTracker.translatesAutoresizingMaskIntoConstraints = false
        
        growthTracker.initTrackerOfType(.growth)
        growthTracker.alpha = 0
        growthTracker.translatesAutoresizingMaskIntoConstraints = false
        
        animalTracker.initTrackerOfType(.animal)
        animalTracker.alpha = 0
        animalTracker.translatesAutoresizingMaskIntoConstraints = false
        
        forestTracker.initTrackerOfType(.forest)
        forestTracker.alpha = 0
        forestTracker.translatesAutoresizingMaskIntoConstraints = false
        
        skyTracker.initTrackerOfType(.sky)
        skyTracker.alpha = 0
        skyTracker.translatesAutoresizingMaskIntoConstraints = false
        
        victoryTracker.initTrackerOfType(.victory)
        victoryTracker.alpha = 0
        victoryTracker.translatesAutoresizingMaskIntoConstraints = false
        
        wildTracker.initTrackerOfType(.wild)
        wildTracker.alpha = 0
        wildTracker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(manaTracker)
        view.addSubview(decayTracker)
        view.addSubview(growthTracker)
        view.addSubview(animalTracker)
        view.addSubview(forestTracker)
        view.addSubview(skyTracker)
        view.addSubview(victoryTracker)
        view.addSubview(wildTracker)
        
        decayTracker.topAnchor.constraint(equalTo: playerPanel.bottomAnchor, constant: 50).isActive = true
        decayTracker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        decayTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        decayTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        manaTracker.topAnchor.constraint(equalTo: playerPanel.bottomAnchor, constant: 10).isActive = true
        manaTracker.leftAnchor.constraint(equalTo: decayTracker.rightAnchor, constant: 10).isActive = true
        manaTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        manaTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        growthTracker.topAnchor.constraint(equalTo: playerPanel.bottomAnchor, constant: 50).isActive = true
        growthTracker.leftAnchor.constraint(equalTo: manaTracker.rightAnchor, constant: 10).isActive = true
        growthTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        growthTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        animalTracker.topAnchor.constraint(equalTo: growthTracker.bottomAnchor, constant: 30).isActive = true
        animalTracker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        animalTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        animalTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        victoryTracker.topAnchor.constraint(equalTo: manaTracker.bottomAnchor, constant: 30).isActive = true
        victoryTracker.leftAnchor.constraint(equalTo: animalTracker.rightAnchor, constant: 10).isActive = true
        victoryTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        victoryTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        forestTracker.topAnchor.constraint(equalTo: decayTracker.bottomAnchor, constant: 30).isActive = true
        forestTracker.leftAnchor.constraint(equalTo: victoryTracker.rightAnchor, constant: 10).isActive = true
        forestTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        forestTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        skyTracker.topAnchor.constraint(equalTo: animalTracker.bottomAnchor, constant: 20).isActive = true
        skyTracker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        skyTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        skyTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        wildTracker.topAnchor.constraint(equalTo: forestTracker.bottomAnchor, constant: 20).isActive = true
        wildTracker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        wildTracker.widthAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        wildTracker.heightAnchor.constraint(equalToConstant: trackerWidth).isActive = true
        
        trackersArray = [manaTracker, decayTracker, growthTracker, animalTracker, forestTracker, skyTracker, victoryTracker, wildTracker]
        constantArray = [player.manaConstant, player.decayConstant, player.growthConstant, player.animalConstant, player.forestConstant, player.skyConstant, player.currentVP, player.wildConstant]
    }
    
    func layoutEndTurnButton() {            //MARK: TEMPORARY FUNCTION -- NEEDS REPLACED WITH KCFLOATINGACTIONBUTTON
        endTurnButton.setTitle("End Turn", for: .normal)
        endTurnButton.addTarget(self, action: #selector(endPlayerTurn(sender:)), for: .touchUpInside)
        endTurnButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(endTurnButton)
        
        endTurnButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        endTurnButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        endTurnButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        endTurnButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playersTableCell") as! PlayersTableCell
        cell.layoutCell(forPlayer: players[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
}
