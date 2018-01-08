//
//  GameLobbyCell.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class GameLobbyCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
    }
    
    func layoutWaitingForPlayersCell() {
        clearCell()
        
        let waitingForPlayersLabel = UILabel()
        waitingForPlayersLabel.font = UIFont(name: fontFamily, size: 15)
        waitingForPlayersLabel.text = "Waiting for players..."
        waitingForPlayersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let spinner = UIActivityIndicatorView()
        spinner.color = .black
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(waitingForPlayersLabel)
        self.addSubview(spinner)
        
        waitingForPlayersLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        waitingForPlayersLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        spinner.topAnchor.constraint(equalTo: waitingForPlayersLabel.bottomAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        spinner.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        spinner.startAnimating()
    }

    func layoutCellForHost(withUser user: Dictionary<String,AnyObject>) {
        clearCell()
        
        guard let username = user["username"] as? String else { return }
        guard let deck = user["deck"] as? String else { return }
        var deckType: DeckType? {
            switch deck {
            case "beastbrothers": return .beastbrothers
            case "dawnseekers": return .dawnseekers
            case "lifewardens": return .lifewardens
            case "waveguards": return .waveguards
            default: return nil
            }
        }
        
        let playerStack = UIStackView()
        playerStack.alignment = .fill
        playerStack.axis = .horizontal
        playerStack.distribution = .equalSpacing
        playerStack.spacing = 5
        playerStack.translatesAutoresizingMaskIntoConstraints = false
        
        let deckIcon = CircleView()
        deckIcon.addBorder()
        deckIcon.addImage((deckType?.image)!, withWidthModifier: 10)
        deckIcon.backgroundColor = deckType?.color
        deckIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let usernameLabel = UILabel()
        usernameLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 15)
        usernameLabel.text = username
        usernameLabel.textAlignment = .center
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        playerStack.addArrangedSubview(deckIcon)
        playerStack.addArrangedSubview(usernameLabel)
        self.addSubview(playerStack)
        
        playerStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        playerStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        playerStack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        deckIcon.widthAnchor.constraint(equalTo: deckIcon.heightAnchor).isActive = true
    }
    
    func layoutStartGameCell() {
        clearCell()
        
        let startLabel = UILabel()
        startLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 20)
        startLabel.text = "Start Game!"
        startLabel.textAlignment = .center
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(startLabel)
        
        startLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        startLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
        startLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        startLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 5).isActive = true
    }
    
    func layoutCellForGuest(withGame game: Dictionary<String,Any>) {
        clearCell()
        
        guard let hostName = game["username"] as? String else { return }
        guard let winCondition = game["winCondition"] as? String else { return }
        guard let vpGoal = game["vpGoal"] as? Int else { return }
        guard let playersArray = game["players"] as? [Dictionary<String,AnyObject>] else { return }
        
        let deckStack = configureDeckChoicesStackView(withPlayers: playersArray)
        var winConditionString: String {
            switch winCondition {
            case "custom": return "custom (\(vpGoal))"
            case "standard": return "standard"
            default: return ""
            }
        }
        
        let gameHostLabel = UILabel()
        gameHostLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 15)
        gameHostLabel.text = hostName
        gameHostLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let winConditionLabel = UILabel()
        winConditionLabel.font = UIFont(name: fontFamily, size: 12)
        winConditionLabel.textAlignment = .right
        winConditionLabel.text = winConditionString
        winConditionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let playersLabel = UILabel()
        var players: String = "" {
            didSet {
                playersLabel.text = players
            }
        }
        playersLabel.font = UIFont(name: fontFamily, size: 10)
        playersLabel.numberOfLines = 1
        playersLabel.translatesAutoresizingMaskIntoConstraints = false
        for i in 0..<playersArray.count {
            if players == "" {
                players = playersArray[i]["username"] as! String
            } else {
                players = "\(players), \(playersArray[i]["username"] as! String)"
            }
        }
        
        self.addSubview(gameHostLabel)
        self.addSubview(winConditionLabel)
        self.addSubview(playersLabel)
        self.addSubview(deckStack)
        
        gameHostLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        gameHostLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        
        winConditionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        winConditionLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        
        playersLabel.topAnchor.constraint(equalTo: gameHostLabel.bottomAnchor, constant: 5).isActive = true
        playersLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        playersLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        
        deckStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        deckStack.leftAnchor.constraint(equalTo: gameHostLabel.rightAnchor, constant: 5).isActive = true
        deckStack.widthAnchor.constraint(equalToConstant: 84.32).isActive = true
        deckStack.heightAnchor.constraint(equalTo: gameHostLabel.heightAnchor).isActive = true
    }
    
    func configureDeckChoicesStackView(withPlayers playersArray: [Dictionary<String,AnyObject>]) -> UIStackView {
        let deckStack = UIStackView()
        deckStack.alignment = .fill
        deckStack.axis = .horizontal
        deckStack.spacing = 5
        deckStack.distribution = .fillEqually
        deckStack.translatesAutoresizingMaskIntoConstraints = false
        
        var beastbrothersTaken = false
        var dawnseekersTaken = false
        var lifewardensTaken = false
        var waveguardsTaken = false
        
        for player in playersArray {
            guard let deck = player["deck"] as? String else { break }
            switch deck {
            case "beastbrothers": beastbrothersTaken = true
            case "dawnseekers": dawnseekersTaken = true
            case "lifewardens": lifewardensTaken = true
            case "waveguards": waveguardsTaken = true
            default: break
            }
        }
        
        var beastbrothersColor: UIColor {
            switch beastbrothersTaken {
            case true: return DeckType.beastbrothers.secondaryColor
            case false: return DeckType.beastbrothers.color
            }
        }
        
        var dawnseekersColor: UIColor {
            switch dawnseekersTaken {
            case true: return DeckType.dawnseekers.secondaryColor
            case false: return DeckType.dawnseekers.color
            }
        }
        
        var lifewardensColor: UIColor {
            switch lifewardensTaken {
            case true: return DeckType.lifewardens.secondaryColor
            case false: return DeckType.lifewardens.color
            }
        }
        
        var waveguardsColor: UIColor {
            switch waveguardsTaken {
            case true: return DeckType.waveguards.secondaryColor
            case false: return DeckType.waveguards.color
            }
        }
        
        let beastbrothers = CircleView()
        beastbrothers.addBorder()
        beastbrothers.backgroundColor = beastbrothersColor
        beastbrothers.translatesAutoresizingMaskIntoConstraints = false
        
        let dawnseekers = CircleView()
        dawnseekers.addBorder()
        dawnseekers.backgroundColor = dawnseekersColor
        dawnseekers.translatesAutoresizingMaskIntoConstraints = false
        
        let lifewardens = CircleView()
        lifewardens.addBorder()
        lifewardens.backgroundColor = lifewardensColor
        lifewardens.translatesAutoresizingMaskIntoConstraints = false
        
        let waveguards = CircleView()
        waveguards.addBorder()
        waveguards.backgroundColor = waveguardsColor
        waveguards.translatesAutoresizingMaskIntoConstraints = false
        
        deckStack.addArrangedSubview(beastbrothers)
        deckStack.addArrangedSubview(dawnseekers)
        deckStack.addArrangedSubview(lifewardens)
        deckStack.addArrangedSubview(waveguards)
        
        return deckStack
    }
}
