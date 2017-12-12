//
//  HomeLayout.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/27/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import KCFloatingActionButton
import GoogleMobileAds
import MapKit
import GMStepper

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func layoutView() {
        layoutBackgroundImage()
        layoutPlayerIcon()
        layoutPlayerName()
        layoutDeckChoices()
        layoutStartButtons()
        layoutBannerAds()
    }
    
    func layoutBackgroundImage() {
        backgroundImage.image = #imageLiteral(resourceName: "homeBG")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.alpha = 0.5
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImage)
        
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func layoutPlayerIcon() {
        playerIcon.addBorder()
        playerIcon.backgroundColor = DeckType.beastbrothers.color
        playerIcon.addImage(DeckType.beastbrothers.image)
        playerIcon.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playerIcon)
        
        playerIcon.widthAnchor.constraint(equalToConstant: 100).isActive = true
        playerIcon.heightAnchor.constraint(equalToConstant: 100).isActive = true
        playerIcon.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        playerIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func layoutPlayerName() {
        playerName.textColor = .darkText
        playerName.font = UIFont(name: "\(fontFamily)-Bold", size: 20)
        playerName.translatesAutoresizingMaskIntoConstraints = false
        playerName.text = "playerName"
        
        view.addSubview(playerName)
        
        playerName.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playerName.topAnchor.constraint(equalTo: playerIcon.bottomAnchor, constant: 20).isActive = true
    }
    
    func layoutDeckChoices() {
        beastbrothersIcon.addBorder()
        beastbrothersIcon.backgroundColor = DeckType.beastbrothers.color
        beastbrothersIcon.addImage(DeckType.beastbrothers.image)
        beastbrothersIcon.translatesAutoresizingMaskIntoConstraints = false
        beastbrothersIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        beastbrothersIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        dawnseekersIcon.addBorder()
        dawnseekersIcon.backgroundColor = DeckType.dawnseekers.color
        dawnseekersIcon.addImage(DeckType.dawnseekers.image)
        dawnseekersIcon.translatesAutoresizingMaskIntoConstraints = false
        dawnseekersIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        dawnseekersIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        lifewardensIcon.addBorder()
        lifewardensIcon.backgroundColor = DeckType.lifewardens.color
        lifewardensIcon.addImage(DeckType.lifewardens.image)
        lifewardensIcon.translatesAutoresizingMaskIntoConstraints = false
        lifewardensIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        lifewardensIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        waveguardsIcon.addBorder()
        waveguardsIcon.backgroundColor = DeckType.waveguards.color
        waveguardsIcon.addImage(DeckType.waveguards.image)
        waveguardsIcon.translatesAutoresizingMaskIntoConstraints = false
        waveguardsIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        waveguardsIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        deckChoicesStackView.axis = UILayoutConstraintAxis.horizontal
        deckChoicesStackView.distribution = .equalSpacing
        deckChoicesStackView.alignment = .center
        deckChoicesStackView.spacing = 10
        deckChoicesStackView.addArrangedSubview(beastbrothersIcon)
        deckChoicesStackView.addArrangedSubview(dawnseekersIcon)
        deckChoicesStackView.addArrangedSubview(lifewardensIcon)
        deckChoicesStackView.addArrangedSubview(waveguardsIcon)
        deckChoicesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(deckChoicesStackView)
        
        deckChoicesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deckChoicesStackView.topAnchor.constraint(equalTo: playerName.bottomAnchor, constant: 10).isActive = true
        deckChoicesStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        deckChoicesStackView.widthAnchor.constraint(equalToConstant: 230).isActive = true
    }
    
    func layoutStartButtons() {
        startButton.buttonColor = .black
        startButton.paddingX = view.frame.width / 2 - startButton.frame.width / 2
        startButton.setPaddingY()
        
        let startGame = KCFloatingActionButtonItem()
        startGame.title = "Start Game"
        startGame.buttonColor = .white
        startGame.handler = { item in
            if self.currentUserID == nil {
                self.performSegue(withIdentifier: "showFirebaseLogin", sender: nil)
            } else {
                if PREMIUM_PURCHASED {
                    self.layoutGameSetupView()
                } else {
                    //TODO: Actions for non-premium
                }
            }
        }
        
        let joinGame = KCFloatingActionButtonItem()
        joinGame.title = "Join Game"
        joinGame.buttonColor = .white
        joinGame.handler = { item in
            if self.currentUserID == nil {
                self.performSegue(withIdentifier: "showFirebaseLogin", sender: nil)
            } else {
                self.joinGamePressed()
            }
        }
        
        let settings = KCFloatingActionButtonItem()
        settings.title = "Settings"
        settings.buttonColor = .red
        settings.handler = { item in
            if self.currentUserID == nil {
                self.performSegue(withIdentifier: "showFirebaseLogin", sender: nil)
            } else {
                self.performSegue(withIdentifier: "showSettings", sender: nil)
            }
        }
        
        startButton.addItem(item: settings)
        startButton.addItem(item: startGame)
        startButton.addItem(item: joinGame)
        
        view.addSubview(startButton)
    }
    
    func layoutGameSetupView() {
        self.userIsHostingGame = true
        
        let gameSetupView = UIView()
        gameSetupView.frame = view.bounds
        gameSetupView.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0.75)
        gameSetupView.alpha = 0
        gameSetupView.tag = 1000
        
        let vpSelector = KCFloatingActionButton()
        vpSelector.buttonColor = .black
        vpSelector.setPaddingY()
        
        let cancel = KCFloatingActionButtonItem()
        cancel.title = "Cancel"
        cancel.buttonColor = .white
        cancel.handler = { item in
            gameSetupView.fadeAlphaOut()
        }
        
        let standard = KCFloatingActionButtonItem()
        standard.title = "Standard VP"
        standard.buttonColor = .white
        standard.handler = { item in
            self.hostGameAndObserve(withWinCondition: "standard", andVPGoal: 0)
            gameSetupView.fadeAlphaOut()
        }
        
        let custom = KCFloatingActionButtonItem()
        custom.title = "Custom VP"
        custom.buttonColor = .white
        custom.handler = { item in
            vpSelector.fadeAlphaOut()
            self.layoutCustomVPSelector()
        }
        
        vpSelector.addItem(item: cancel)
        vpSelector.addItem(item: standard)
        if PREMIUM_PURCHASED { vpSelector.addItem(item: custom) }
        
        view.addSubview(gameSetupView)
        gameSetupView.addSubview(vpSelector)
        gameSetupView.fadeAlphaTo(0.75, withDuration: 0.2)
    }
    
    func layoutCustomVPSelector() {
        //TODO: Beautify
        let vpStepper = GMStepper()
        vpStepper.buttonsBackgroundColor = primaryColor
        vpStepper.labelBackgroundColor = secondaryColor
        vpStepper.labelFont = UIFont(name: fontFamily, size: 25)!
        vpStepper.value = 23
        vpStepper.maximumValue = 500
        vpStepper.translatesAutoresizingMaskIntoConstraints = false
        
        let menuButton = KCFloatingActionButton()
        menuButton.setPaddingY()
        menuButton.buttonColor = .black
        
        let cancel = KCFloatingActionButtonItem()
        cancel.title = "Cancel"
        cancel.buttonColor = .white
        cancel.handler = {item in
            vpStepper.fadeAlphaOut()
            menuButton.fadeAlphaOut()
            for subview in self.view.subviews {
                if subview.tag == 1000 {
                    subview.fadeAlphaOut()
                }
            }
        }
        
        let done = KCFloatingActionButtonItem()
        done.title = "Done"
        done.buttonColor = .white
        done.handler = { item in
            let vpGoal = vpStepper.value
            self.hostGameAndObserve(withWinCondition: "custom", andVPGoal: Int(vpGoal))
            for subview in self.view.subviews {
                if subview.tag == 1000 {
                    subview.fadeAlphaOut()
                }
            }
        }
        
        menuButton.addItem(item: cancel)
        menuButton.addItem(item: done)
        
        view.addSubview(vpStepper)
        view.addSubview(menuButton)
        
        vpStepper.heightAnchor.constraint(equalToConstant: 50).isActive = true
        vpStepper.widthAnchor.constraint(equalToConstant: 150).isActive = true
        vpStepper.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        vpStepper.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func layoutBannerAds() {
        if PREMIUM_PURCHASED {
            adBanner.removeFromSuperview()
        } else {
            //MARK: Initialize banner ads
//            adBanner.adUnitID = "ca-app-pub-4384472824519738/9844119805"  //My ads
            adBanner.adUnitID = "ca-app-pub-3940256099942544/6300978111"    //Test ads
            adBanner.backgroundColor = .white
            adBanner.rootViewController = self
            adBanner.load(GADRequest())
            adBanner.translatesAutoresizingMaskIntoConstraints = false
        
            view.addSubview(adBanner)
        
            adBanner.heightAnchor.constraint(equalToConstant: 50).isActive = true
            adBanner.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            adBanner.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }
    
    func layoutGameLobby() {
        var bottomConstant: CGFloat {
            if PREMIUM_PURCHASED {
                return 85
            } else {
                return 135
            }
        }
        
        gameLobbyTable.dataSource = self
        gameLobbyTable.delegate = self
        gameLobbyTable.separatorStyle = .none
        gameLobbyTable.backgroundColor = .clear
        gameLobbyTable.clearsContextBeforeDrawing = true
        gameLobbyTable.rowHeight = 35
        gameLobbyTable.register(GameLobbyCell.self, forCellReuseIdentifier: "gameLobbyCell")
        gameLobbyTable.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(gameLobbyTable)
        
        gameLobbyTable.topAnchor.constraint(equalTo: deckChoicesStackView.bottomAnchor, constant: 10).isActive = true
        gameLobbyTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        gameLobbyTable.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        gameLobbyTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomConstant).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userIsHostingGame {
            switch players.count {
            case 1: return players.count + 1
            case 2...3: return players.count + 2
            case 4: return players.count + 1
            default: return 0
            }
        } else {
            return nearbyGames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameLobbyCell", for: indexPath) as! GameLobbyCell
        if userIsHostingGame {
            if players.count == 1 {
                if indexPath.row == 0 {
                    cell.layoutWaitingForPlayersCell()
                } else {
                    cell.layoutCellForHost(withUser: players[indexPath.row - 1])
                }
            } else if players.count == 2 {
                if indexPath.row == 0 {
                    cell.layoutWaitingForPlayersCell()
                } else if indexPath.row > 0 && indexPath.row < 3 {
                    cell.layoutCellForHost(withUser: players[indexPath.row - 1])
                } else if indexPath.row == 3 {
                    cell.layoutStartGameCell()
                }
            } else if players.count == 3 {
                if indexPath.row == 0 {
                    cell.layoutWaitingForPlayersCell()
                } else if indexPath.row > 0 && indexPath.row < 4 {
                    cell.layoutCellForHost(withUser: players[indexPath.row - 1])
                } else if indexPath.row == 4 {
                    cell.layoutStartGameCell()
                }
            } else if players.count == 4 {
                if indexPath.row == 0 {
                    cell.layoutCellForHost(withUser: players[indexPath.row])
                } else if indexPath.row > 0 && indexPath.row < 4 {
                    cell.layoutCellForHost(withUser: players[indexPath.row])
                } else if indexPath.row == 4 {
                    cell.layoutStartGameCell()
                }
            }
        } else {
            cell.layoutCellForGuest(withGame: nearbyGames[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if userIsHostingGame {
            var index: Int {
                switch players.count {
                case 2: return 3
                case 3: return 4
                case 4: return 5
                default: return 0
                }
            }
            if indexPath.row == index {
                GameHandler.instance.updateFirebaseDBGame(key: currentUserID!, gameData: ["gameStarted" : true])
                performSegue(withIdentifier: "startGame", sender: nil)
            }
        } else {
            removeUserFromAllGames()
            let userData: Dictionary<String,AnyObject> = ["username" : self.username as AnyObject,
                                                          "deck" : player.deck?.rawValue as AnyObject,
                                                          "victoryPoints" : 0 as AnyObject,
                                                          "boxVictory" : 0 as AnyObject]
            updateGame(forGame: nearbyGames[indexPath.row], withUserData: userData)
            observeGamesForStart(forGame: nearbyGames[indexPath.row])
            let userLoaction = self.locationManager.location
            observeGames(withUserLocation: userLoaction!)
            //TODO: Display waiting message
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
