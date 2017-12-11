//
//  GameLobbyCell.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class GameLobbyCell: UITableViewCell {
    override func awakeFromNib() {
        self.backgroundColor = .clear
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
    }
    
    func clearCell() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
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
        let deck = user["deck"] as! String
        let username = user["username"] as! String
        var deckColor: UIColor? {
            switch deck {
            case "beasebrothers": return red
            case "dawnseekers": return yellow
            case "lifewardens": return green
            case "waveguards": return blue
            default: return nil
            }
        }
        
        clearCell()
        self.backgroundColor = deckColor
        
        let usernameLabel = UILabel()
        usernameLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 15)
        usernameLabel.text = username
        usernameLabel.textAlignment = .center
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(usernameLabel)
        
        usernameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        usernameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
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
        
        let hostName = game["username"] as? String
        let winCondition = game["winCondition"] as! String
        guard let playersArray = game["players"] as? [Dictionary<String,AnyObject>] else {
            print("no players...?")
            return
        }
        
        let gameHostLabel = UILabel()
        gameHostLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 15)
        gameHostLabel.text = hostName!
        gameHostLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let winConditionLabel = UILabel()
        winConditionLabel.font = UIFont(name: fontFamily, size: 12)
        winConditionLabel.textAlignment = .right
        winConditionLabel.text = winCondition
        winConditionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let playersLabel = UILabel()
        var players: String = "" {
            didSet {
                playersLabel.text = players
            }
        }
        playersLabel.font = UIFont(name: fontFamily, size: 10)
        playersLabel.numberOfLines = 0
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
        
        gameHostLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        gameHostLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        
        winConditionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        winConditionLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        playersLabel.topAnchor.constraint(equalTo: gameHostLabel.bottomAnchor, constant: 5).isActive = true
        playersLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        playersLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
}
