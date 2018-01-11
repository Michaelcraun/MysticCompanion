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
        layoutMenuButton()
        layoutBannerAds()
    }
    
    func reinitializeView() {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        layoutView()
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
        playerIcon.addImage(DeckType.beastbrothers.image, withWidthModifier: 20)
        playerIcon.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playerIcon)
        
        playerIcon.widthAnchor.constraint(equalToConstant: 100).isActive = true
        playerIcon.heightAnchor.constraint(equalToConstant: 100).isActive = true
        playerIcon.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
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
        beastbrothersIcon.addImage(DeckType.beastbrothers.image, withWidthModifier: 20)
        beastbrothersIcon.translatesAutoresizingMaskIntoConstraints = false
        beastbrothersIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        beastbrothersIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        dawnseekersIcon.addBorder()
        dawnseekersIcon.backgroundColor = DeckType.dawnseekers.color
        dawnseekersIcon.addImage(DeckType.dawnseekers.image, withWidthModifier: 20)
        dawnseekersIcon.translatesAutoresizingMaskIntoConstraints = false
        dawnseekersIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        dawnseekersIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        lifewardensIcon.addBorder()
        lifewardensIcon.backgroundColor = DeckType.lifewardens.color
        lifewardensIcon.addImage(DeckType.lifewardens.image, withWidthModifier: 20)
        lifewardensIcon.translatesAutoresizingMaskIntoConstraints = false
        lifewardensIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        lifewardensIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        waveguardsIcon.addBorder()
        waveguardsIcon.backgroundColor = DeckType.waveguards.color
        waveguardsIcon.addImage(DeckType.waveguards.image, withWidthModifier: 20)
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
    
    func layoutMenuButton() {
        menuButton.setMenuButtonColor()
        menuButton.setPaddingY()
        menuButton.items = []
        
        let startGame = KCFloatingActionButtonItem()
        startGame.setButtonOfType(.startGame)
        startGame.handler = { item in
            if self.currentUserID == nil {
                self.performSegue(withIdentifier: "showFirebaseLogin", sender: nil)
            } else {
                self.layoutGameSetupView()
            }
        }
        
        let joinGame = KCFloatingActionButtonItem()
        joinGame.setButtonOfType(.joinGame)
        joinGame.handler = { item in
            if self.currentUserID == nil {
                self.performSegue(withIdentifier: "showFirebaseLogin", sender: nil)
            } else {
                self.joinGamePressed()
            }
        }
        
        let settings = KCFloatingActionButtonItem()
        settings.setButtonOfType(.settings)
        settings.handler = { item in
            if self.currentUserID == nil {
                self.performSegue(withIdentifier: "showFirebaseLogin", sender: nil)
            } else {
                self.performSegue(withIdentifier: "showSettings", sender: nil)
            }
        }
        
        menuButton.addItem(item: settings)
        menuButton.addItem(item: startGame)
        menuButton.addItem(item: joinGame)
        
        view.addSubview(menuButton)
    }
    
    func layoutGameSetupView() {
        self.userIsHostingGame = true
        view.addBlurEffect()
        guard let blurEffectView = view.viewWithTag(1001) as? UIVisualEffectView else { return }
        
        let vpSelector = KCFloatingActionButton()
        vpSelector.setMenuButtonColor()
        vpSelector.setPaddingY()
        
        let cancel = KCFloatingActionButtonItem()
        cancel.setButtonOfType(.cancel)
        cancel.handler = { item in
            blurEffectView.fadeAlphaOut()
        }
        
        let standard = KCFloatingActionButtonItem()
        standard.setButtonOfType(.standardVP)
        standard.handler = { item in
            self.hostGameAndObserve(withWinCondition: "standard", andVPGoal: 0)
            blurEffectView.fadeAlphaOut()
        }
        
        let custom = KCFloatingActionButtonItem()
        custom.setButtonOfType(.customVP)
        custom.handler = { item in
            vpSelector.fadeAlphaOut()
            self.layoutCustomVPSelector()
        }
        
        vpSelector.addItem(item: cancel)
        vpSelector.addItem(item: standard)
        if PREMIUM_PURCHASED { vpSelector.addItem(item: custom) }
        
        blurEffectView.contentView.addSubview(vpSelector)
        blurEffectView.fadeAlphaTo(1, withDuration: 0.2)
    }
    
    func layoutCustomVPSelector() {
        let vpStepper = GMStepper()
        vpStepper.buttonsBackgroundColor = theme.color
        vpStepper.labelBackgroundColor = theme.color1
        vpStepper.borderColor = theme.color
        vpStepper.borderWidth = 1
        vpStepper.labelFont = UIFont(name: fontFamily, size: 25)!
        vpStepper.value = 23
        vpStepper.maximumValue = 500
        vpStepper.translatesAutoresizingMaskIntoConstraints = false
        
        let menuButton = KCFloatingActionButton()
        menuButton.setPaddingY()
        menuButton.setMenuButtonColor()
        
        let cancel = KCFloatingActionButtonItem()
        cancel.setButtonOfType(.cancel)
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
        done.setButtonOfType(.done)
        done.handler = { item in
            let vpGoal = vpStepper.value
            self.hostGameAndObserve(withWinCondition: "custom", andVPGoal: Int(vpGoal))
            vpStepper.fadeAlphaOut()
            menuButton.fadeAlphaOut()
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
        if !PREMIUM_PURCHASED {
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
                return 95
            } else {
                return 145
            }
        }
        
        gameLobby = UIView()
        gameLobby.backgroundColor = .clear
        gameLobby.clipsToBounds = true
        gameLobby.layer.cornerRadius = 15
        gameLobby.layer.borderColor = UIColor.black.cgColor
        gameLobby.layer.borderWidth = 2
        gameLobby.translatesAutoresizingMaskIntoConstraints = false
        
        gameLobbyTable.dataSource = self
        gameLobbyTable.delegate = self
        gameLobbyTable.separatorStyle = .none
        gameLobbyTable.backgroundColor = .clear
        gameLobbyTable.register(GameLobbyCell.self, forCellReuseIdentifier: "gameLobbyCell")
        gameLobbyTable.translatesAutoresizingMaskIntoConstraints = false
        
        gameLobby.addBlurEffect()
        gameLobby.addSubview(gameLobbyTable)
        view.addSubview(gameLobby)
        
        gameLobby.topAnchor.constraint(equalTo: deckChoicesStackView.bottomAnchor, constant: 20).isActive = true
        gameLobby.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        gameLobby.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        gameLobby.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomConstant).isActive = true
        
        gameLobbyTable.topAnchor.constraint(equalTo: gameLobby.topAnchor, constant: 5).isActive = true
        gameLobbyTable.leftAnchor.constraint(equalTo: gameLobby.leftAnchor, constant: 5).isActive = true
        gameLobbyTable.rightAnchor.constraint(equalTo: gameLobby.rightAnchor, constant: -5).isActive = true
        gameLobbyTable.bottomAnchor.constraint(equalTo: gameLobby.bottomAnchor, constant: -5).isActive = true
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
        tableView.beginUpdates()
        if userIsHostingGame {
            //TODO: Refactor
            if players.count == 1 {
                if indexPath.row == 0 {
                    cell.layoutWaitingCell(withMessage: "Waiting for players...")
                } else {
                    cell.layoutCellForHost(withUser: players[indexPath.row - 1])
                }
            } else if players.count == 2 {
                if indexPath.row == 0 {
                    cell.layoutWaitingCell(withMessage: "Waiting for players...")
                } else if indexPath.row > 0 && indexPath.row < 3 {
                    cell.layoutCellForHost(withUser: players[indexPath.row - 1])
                } else if indexPath.row == 3 {
                    cell.layoutStartGameCell()
                }
            } else if players.count == 3 {
                if indexPath.row == 0 {
                    cell.layoutWaitingCell(withMessage: "Waiting for players...")
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
            //TODO: layout waiting for games cell
            if nearbyGames.count <= 0 {
                cell.layoutCellForGuest(withGame: nearbyGames[indexPath.row])
            } else {
                cell.layoutWaitingCell(withMessage: "Waiting for games...")
            }
        }
        tableView.endUpdates()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if userIsHostingGame {
            var startGameIndex: Int {
                switch players.count {
                case 2: return 3
                case 3: return 4
                case 4: return 5
                default: return 0
                }
            }
            if indexPath.row == startGameIndex {
                GameHandler.instance.updateFirebaseDBGame(key: currentUserID!, gameData: ["gameStarted" : true])
                performSegue(withIdentifier: "startGame", sender: nil)
            }
        } else {
            let userData: Dictionary<String,AnyObject> = ["username" : Player.instance.username as AnyObject,
                                                          "deck" : Player.instance.deck?.rawValue as AnyObject,
                                                          "finished" : false as AnyObject,
                                                          "victoryPoints" : 0 as AnyObject,
                                                          "userHasQuitGame" : false as AnyObject,
                                                          "boxVictory" : 0 as AnyObject]
            GameHandler.instance.game = nearbyGames[indexPath.row]
            updateGame(withUserData: userData)
            observeGameForStart()
            //TODO: Display waiting message
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellDelay = TimeInterval(indexPath.row - 1) / 10
        tableView.animate(cell, shouldBeVisible: false, withDelay: cellDelay)
    }
}
