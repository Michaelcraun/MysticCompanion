//
//  GameLobbyCell.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class GameLobbyCell: UITableViewCell {
    var user = [String : Any]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
    }
    
    /// Configures the cell to display a waiting message (for when user's are waiting on the actions of other users)
    /// - parameter message: The message to be displayed to the user
    func layoutWaitingCell(withMessage message: String) {
        clearCell()
        
        let waitingForPlayersLabel = UILabel()
        waitingForPlayersLabel.font = UIFont(name: fontFamily, size: 15)
        waitingForPlayersLabel.text = message
        waitingForPlayersLabel.anchorTo(self,
                                        top: self.topAnchor,
                                        centerX: self.centerXAnchor)
        
        let spinner = UIActivityIndicatorView()
        spinner.color = .black
        spinner.anchorTo(self,
                         top: waitingForPlayersLabel.bottomAnchor,
                         bottom: self.bottomAnchor,
                         centerX: self.centerXAnchor)
        spinner.startAnimating()
    }

    /// Configures the cell for the host to display a user that has joined the game
    /// - parameter user: A Dictionary value that represents a specific user
    func layoutCellForHost(withUser user: [String : Any]) {
        clearCell()
        self.user = user
        
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
        playerStack.anchorTo(self,
                             top: self.topAnchor,
                             bottom: self.bottomAnchor,
                             centerX: self.centerXAnchor,
                             padding: .init(top: 5, left: 0, bottom: 5, right: 0))
        
        let deckIcon = CircleView()
        deckIcon.addImage((deckType?.image)!, withSize: 20)
        deckIcon.backgroundColor = deckType?.color
        deckIcon.anchorTo(size: .init(width: 30, height: 30))
        
        let usernameLabel = UILabel()
        usernameLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 15)
        usernameLabel.text = username
        usernameLabel.textAlignment = .center
        deckIcon.anchorTo()
        
        playerStack.addArrangedSubview(deckIcon)
        playerStack.addArrangedSubview(usernameLabel)
    }
    
    /// Configures a cell to display the option to start the game to the host of the game
    func layoutStartGameCell() {
        clearCell()
        
        let startLabel = UILabel()
        startLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 20)
        startLabel.text = "Start Game!"
        startLabel.textAlignment = .center
        startLabel.fillTo(self, padding: .init(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    /// Configures a cell to display a nearby, joinable game
    /// - parameter game: A Dictionary value containing the specified game's data
    func layoutCellForGuest(withGame game: [String : Any]) {
        clearCell()
        
        guard let hostName =    game[FIRKey.username.rawValue] as? String,
            let winCondition =  game[FIRKey.winCondition.rawValue] as? String,
            let vpGoal =        game[FIRKey.vpGoal.rawValue] as? Int,
            let playersArray =  game[FIRKey.players.rawValue] as? [[String : AnyObject]] else { return }
        
        let gameHostLabel = UILabel()
        gameHostLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 15)
        gameHostLabel.text = hostName
        gameHostLabel.anchorTo(self,
                               top: self.topAnchor,
                               leading: self.leadingAnchor,
                               padding: .init(top: 5, left: 5, bottom: 0, right: 0))
        
        let deckStack = configureDeckChoicesStackView(withPlayers: playersArray)
        deckStack.anchorTo(self,
                           top: self.topAnchor,
                           leading: gameHostLabel.trailingAnchor,
                           padding: .init(top: 5, left: 5, bottom: 0, right: 0),
                           size: .init(width: 85, height: 17.5))
        
        let winConditionLabel = UILabel()
        winConditionLabel.font = UIFont(name: fontFamily, size: 12)
        winConditionLabel.textAlignment = .right
        winConditionLabel.text = {
            var winConditionString: String {
                switch winCondition {
                case "custom": return "custom (\(vpGoal))"
                case "standard": return "standard"
                default: return ""
                }
            }
            
            return winConditionString
        }()
        winConditionLabel.anchorTo(self,
                                   top: self.topAnchor,
                                   trailing: self.trailingAnchor,
                                   padding: .init(top: 5, left: 0, bottom: 0, right: 5))
        
        let playersLabel = UILabel()
        playersLabel.font = UIFont(name: fontFamily, size: 10)
        playersLabel.numberOfLines = 1
        playersLabel.text = {
            var playersString = ""
            for i in 0..<playersArray.count {
                if playersString == "" {
                    playersString = playersArray[i]["username"] as! String
                } else {
                    playersString = "\(playersString), \(playersArray[i]["username"] as! String)"
                }
            }
            return playersString
        }()
        playersLabel.anchorTo(self,
                              top: gameHostLabel.bottomAnchor,
                              leading: self.leadingAnchor,
                              trailing: self.trailingAnchor,
                              padding: .init(top: 5, left: 5, bottom: 0, right: 5))
    }
    
    /// Configures a stackView to display the deck choices for a game (displays taken decks as a dim circle and
    /// available decks as a bright circle)
    /// - parameter playersArray: An Array of Dictionary values representing the player's currently in the game (used
    /// to display the available deck choices)
    func configureDeckChoicesStackView(withPlayers playersArray: [[String : AnyObject]]) -> UIStackView {
        let deckStack = UIStackView()
        deckStack.alignment = .fill
        deckStack.axis = .horizontal
        deckStack.spacing = 5
        deckStack.distribution = .fillEqually
        
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
        beastbrothers.backgroundColor = beastbrothersColor
        beastbrothers.translatesAutoresizingMaskIntoConstraints = false
        
        let dawnseekers = CircleView()
        dawnseekers.backgroundColor = dawnseekersColor
        dawnseekers.translatesAutoresizingMaskIntoConstraints = false
        
        let lifewardens = CircleView()
        lifewardens.backgroundColor = lifewardensColor
        lifewardens.translatesAutoresizingMaskIntoConstraints = false
        
        let waveguards = CircleView()
        waveguards.backgroundColor = waveguardsColor
        waveguards.translatesAutoresizingMaskIntoConstraints = false
        
        deckStack.addArrangedSubview(beastbrothers)
        deckStack.addArrangedSubview(dawnseekers)
        deckStack.addArrangedSubview(lifewardens)
        deckStack.addArrangedSubview(waveguards)
        
        return deckStack
    }
}
