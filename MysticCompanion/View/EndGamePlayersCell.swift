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
        // Initialization code
    }
    
    func configureCell(forPlayer player: Dictionary<String,AnyObject>) {
        print("configureCell(for \(player)")
//        guard let username = player["username"] as? String else { return }
//        guard let deck = player["deck"] as? String else { return }
//        guard let currentVP = player["victoryPoints"] as? Int else { return }
//        guard let boxVP = player["boxVP"] as? Int else { return }
//        var deckType: DeckType? {
//            switch deck {
//            case "beastbrothers": return .beastbrothers
//            case "dawnseekers": return .dawnseekers
//            case "lifewardens": return .lifewardens
//            case "waveguards": return .waveguards
//            default: return nil
//            }
//        }
//        guard let deckImage = deckType?.image else { return }

        let playerView = UIView()
//        playerView.layer.cornerRadius = 10
//        playerView.layer.borderColor = UIColor.black.cgColor
//        playerView.layer.borderWidth = 2
//        playerView.backgroundColor = deckType?.color
        playerView.backgroundColor = .blue
        playerView.translatesAutoresizingMaskIntoConstraints = false

//        let playerIcon = CircleView()
//        playerIcon.addBorder()
//        playerIcon.addImage(deckImage, withWidthModifier: 10)
//        playerIcon.translatesAutoresizingMaskIntoConstraints = false
//
//        let playerUsernameLabel = UILabel()
//        playerUsernameLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 20)
//        playerUsernameLabel.text = username
//        playerUsernameLabel.sizeToFit()
//        playerUsernameLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        let currentVictoryLabel = UILabel()
//        currentVictoryLabel.font = UIFont(name: fontFamily, size: 15)
//        currentVictoryLabel.text = "\(currentVP + boxVP)"
//        currentVictoryLabel.sizeToFit()
//        currentVictoryLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        let deckVictoryStepper = GMStepper()
//        deckVictoryStepper.buttonsBackgroundColor = secondaryColor
//        deckVictoryStepper.labelBackgroundColor = primaryColor
//        deckVictoryStepper.maximumValue = 500
//        deckVictoryStepper.minimumValue = -500
//        deckVictoryStepper.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(playerView)
//        playerView.addSubview(playerIcon)
//        playerView.addSubview(playerUsernameLabel)
//        playerView.addSubview(currentVictoryLabel)
//        playerView.addSubview(deckVictoryStepper)

        playerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        playerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        playerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true

//        playerIcon.heightAnchor.constraint(equalToConstant: playerView.frame.height / 3).isActive = true
//        playerIcon.widthAnchor.constraint(equalToConstant: playerView.frame.height / 3).isActive = true
//        playerIcon.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 10).isActive = true
//        playerIcon.centerYAnchor.constraint(equalTo: playerView.centerYAnchor).isActive = true
//
//        let usernameAndVictoryCenterYConstant = playerUsernameLabel.frame.height / 2 - currentVictoryLabel.frame.height / 2 - 10
//        playerUsernameLabel.leftAnchor.constraint(equalTo: playerIcon.rightAnchor).isActive = true
//        playerUsernameLabel.centerYAnchor.constraint(equalTo: playerView.centerYAnchor, constant: 20).isActive = true
//
//        currentVictoryLabel.centerXAnchor.constraint(equalTo: playerUsernameLabel.centerXAnchor).isActive = true
//        currentVictoryLabel.centerYAnchor.constraint(equalTo: playerView.centerYAnchor, constant: -20).isActive = true
//
//        deckVictoryStepper.rightAnchor.constraint(equalTo: playerView.rightAnchor, constant: -10).isActive = true
//        deckVictoryStepper.leftAnchor.constraint(equalTo: playerUsernameLabel.rightAnchor, constant: 10).isActive = true
//        deckVictoryStepper.centerYAnchor.constraint(equalTo: playerView.centerYAnchor).isActive = true
//        deckVictoryStepper.heightAnchor.constraint(equalToConstant: playerView.frame.height / 3).isActive = true
    }
}
