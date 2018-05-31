//
//  EndGamePlayersCell.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/13/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import GMStepper

class EndGamePlayersCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = .clear
    }
    
    /// Configures the cell for a given player
    /// - parameter player: A Dictionary representing the player and all of it's values
    /// - parameter shouldDisplayStepper: A Boolean value determining if the player's cell should display a stepper for
    /// input of deck victory (should be true only if cell's player is the current player and hasn't already submitted
    /// the victory contained within their deck)
    /// - parameter winners: An Array of type String that contains the username's of the winners of the game
    func configureCell(forPlayer player: [String : AnyObject], shouldDisplayStepper: Bool, withWinners winners: [String]) {
        guard let username = player["username"] as? String else { return }
        guard let deck = player["deck"] as? String else { return }
        guard let currentVP = player["victoryPoints"] as? Int else { return }
        guard let boxVP = player["boxVictory"] as? Int else { return }
        guard let finished = player["finished"] as? Bool else { return }
        var deckType: DeckType? {
            switch deck {
            case "beastbrothers": return .beastbrothers
            case "dawnseekers": return .dawnseekers
            case "lifewardens": return .lifewardens
            case "waveguards": return .waveguards
            default: return nil
            }
        }
        guard let deckImage = deckType?.image else { return }
        
        clearCell()

        let playerView = UIView()
        playerView.addBlurEffect()
        playerView.layer.cornerRadius = 10
        playerView.layer.borderColor = UIColor.black.cgColor
        playerView.layer.borderWidth = 2
        playerView.clipsToBounds = true
        playerView.fillTo(self, padding: .init(top: 5, left: 5, bottom: 5, right: 5))
        
        let playerIcon = CircleView()
        playerIcon.addImage(deckImage, withSize: 10)
        playerIcon.backgroundColor = deckType?.color
        playerIcon.anchorTo(playerView,
                            top: playerView.topAnchor,
                            leading: playerView.leadingAnchor,
                            padding: .init(top: 5, left: 5, bottom: 0, right: 0),
                            size: .init(width: 23, height: 23))
        
        let currentVictoryLabel = UILabel()
        currentVictoryLabel.font = UIFont(name: fontFamily, size: 15)
        currentVictoryLabel.textAlignment = .right
        currentVictoryLabel.text = "\(currentVP + boxVP)"
        currentVictoryLabel.sizeToFit()
        currentVictoryLabel.anchorTo(playerView,
                                     trailing: playerView.trailingAnchor,
                                     centerY: playerIcon.centerYAnchor,
                                     padding: .init(top: 0, left: 0, bottom: 0, right: 5))

        let playerUsernameLabel = UILabel()
        playerUsernameLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 20)
        playerUsernameLabel.textAlignment = .left
        playerUsernameLabel.text = username
        playerUsernameLabel.sizeToFit()
        playerUsernameLabel.tag = 3030
        playerUsernameLabel.anchorTo(playerView,
                                     top: playerView.topAnchor,
                                     leading: playerIcon.trailingAnchor,
                                     trailing: currentVictoryLabel.leadingAnchor,
                                     padding: .init(top: 5, left: 5, bottom: 0, right: 5))

        let finishedImage = UIImageView()
        finishedImage.image = #imageLiteral(resourceName: "doneIcon")
        finishedImage.contentMode = .scaleAspectFit
        
        if username == Player.instance.username {
            if shouldDisplayStepper {
                let deckVictoryStepper = GMStepper()
                deckVictoryStepper.tag = 4040
                deckVictoryStepper.labelFont = UIFont(name: fontFamily, size: 15)!
                deckVictoryStepper.buttonsBackgroundColor = theme.color
                deckVictoryStepper.labelBackgroundColor = theme.color4
                deckVictoryStepper.maximumValue = 500
                deckVictoryStepper.minimumValue = -500
                deckVictoryStepper.anchorTo(playerView,
                                            bottom: playerView.bottomAnchor,
                                            centerX: playerView.centerXAnchor,
                                            padding: .init(top: 0, left: 0, bottom: 5, right: 0),
                                            size: .init(width: 150, height: 25))
            } else {
                finishedImage.anchorTo(playerView,
                                       bottom: playerView.bottomAnchor,
                                       centerX: playerView.centerXAnchor,
                                       padding: .init(top: 0, left: 0, bottom: 5, right: 0),
                                       size: .init(width: 50, height: 50))
            }
        } else {
            if finished {
                finishedImage.anchorTo(playerView,
                                       bottom: playerView.bottomAnchor,
                                       centerX: playerView.centerXAnchor,
                                       padding: .init(top: 0, left: 0, bottom: 5, right: 0),
                                       size: .init(width: 50, height: 50))
            } else {
                playerView.addBlurEffect()
                
                let waitingOnPlayerLabel = UILabel()
                waitingOnPlayerLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 15)
                waitingOnPlayerLabel.textAlignment = .center
                waitingOnPlayerLabel.text = "Waiting on \(username)..."
                waitingOnPlayerLabel.anchorTo(playerView,
                                              top: playerView.topAnchor,
                                              leading: playerView.leadingAnchor,
                                              trailing: playerView.trailingAnchor,
                                              padding: .init(top: 5, left: 5, bottom: 0, right: 5))
                
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.color = .black
                activityIndicator.anchorTo(playerView,
                                           centerX: playerView.centerXAnchor,
                                           centerY: playerView.centerYAnchor)
                activityIndicator.startAnimating()
            }
        }
        
        for winner in winners {
            if username == winner {
                let winnerImage = UIImageView()
                winnerImage.image = #imageLiteral(resourceName: "winner")
                winnerImage.contentMode = .scaleAspectFit
                winnerImage.anchorTo(playerView,
                                     top: playerView.topAnchor,
                                     trailing: playerView.leadingAnchor,
                                     padding: .init(top: 20, left: 0, bottom: 0, right: 0),
                                     size: .init(width: self.frame.width, height: self.frame.height / 3))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    UIView.animate(withDuration: 0.5, animations: {
                        winnerImage.frame.origin.x += self.frame.width
                    })
                })
                break
            }
        }
    }
}
