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

extension HomeVC {
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
        var yPadding: CGFloat {
            switch Shared.instance.PREMIUM_PURCHASED {
            case true: return 20
            case false: return 70
            }
        }
        
        startButton.buttonColor = .black
        startButton.paddingX = view.frame.width / 2 - startButton.frame.width / 2
        startButton.paddingY = yPadding
        
        let startGame = KCFloatingActionButtonItem()
        startGame.title = "Start Game"
        startGame.buttonColor = .white
        startGame.handler = { item in
            
        }
        
        let joinGame = KCFloatingActionButtonItem()
        joinGame.title = "Join Game"
        joinGame.buttonColor = .white
        joinGame.handler = { item in
            
        }
        
        startButton.addItem(item: startGame)
        startButton.addItem(item: joinGame)
        
        view.addSubview(startButton)
    }
    
    func layoutBannerAds() {
        if Shared.instance.PREMIUM_PURCHASED {
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
}
