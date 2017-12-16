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
    }
    
    func clearCell() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func configureCell(forPlayer player: Dictionary<String,AnyObject>) {
        print("configureCell(for \(player)")
        guard let username = player["username"] as? String else { return }
        guard let deck = player["deck"] as? String else { return }
        guard let currentVP = player["victoryPoints"] as? Int else { return }
        guard let boxVP = player["boxVictory"] as? Int else { return }
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
        playerView.layer.cornerRadius = 10
        playerView.layer.borderColor = UIColor.black.cgColor
        playerView.layer.borderWidth = 2
        playerView.backgroundColor = deckType?.secondaryColor
        playerView.translatesAutoresizingMaskIntoConstraints = false
        
        let playerInfoStack = UIStackView()
        playerInfoStack.alignment = .center
        playerInfoStack.axis = .vertical
        playerInfoStack.distribution = .equalCentering
        playerInfoStack.spacing = 10
        playerInfoStack.translatesAutoresizingMaskIntoConstraints = false
        
        let playerIcon = CircleView()
        playerIcon.addBorder()
        playerIcon.addImage(deckImage, withWidthModifier: 10)
        playerIcon.backgroundColor = deckType?.color
        playerIcon.translatesAutoresizingMaskIntoConstraints = false

        let playerUsernameLabel = UILabel()
        playerUsernameLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 20)
        playerUsernameLabel.text = username
        playerUsernameLabel.sizeToFit()
        playerUsernameLabel.translatesAutoresizingMaskIntoConstraints = false

        let currentVictoryLabel = UILabel()
        currentVictoryLabel.font = UIFont(name: fontFamily, size: 15)
        currentVictoryLabel.text = "\(currentVP + boxVP)"
        currentVictoryLabel.sizeToFit()
        currentVictoryLabel.translatesAutoresizingMaskIntoConstraints = false

        let deckVictoryStepper = GMStepper()
        deckVictoryStepper.buttonsBackgroundColor = theme.color
        deckVictoryStepper.labelBackgroundColor = theme.color4
        deckVictoryStepper.maximumValue = 500
        deckVictoryStepper.minimumValue = -500
        deckVictoryStepper.translatesAutoresizingMaskIntoConstraints = false
        
        playerInfoStack.addArrangedSubview(playerIcon)
        playerInfoStack.addArrangedSubview(playerUsernameLabel)
        playerInfoStack.addArrangedSubview(currentVictoryLabel)
        if username == Player.instance.username { playerInfoStack.addArrangedSubview(deckVictoryStepper) }

        self.addSubview(playerView)
        playerView.addSubview(playerInfoStack)

        playerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        playerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        playerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        playerInfoStack.topAnchor.constraint(equalTo: playerView.topAnchor, constant: 10).isActive = true
        playerInfoStack.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 10).isActive = true
        playerInfoStack.rightAnchor.constraint(equalTo: playerView.rightAnchor, constant: -10).isActive = true
        playerInfoStack.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -10).isActive = true
        
        deckVictoryStepper.heightAnchor.constraint(equalToConstant: 50).isActive = true
        deckVictoryStepper.widthAnchor.constraint(equalToConstant: 150).isActive = true

//        playerIcon.heightAnchor.constraint(equalToConstant: playerView.frame.height / 3).isActive = true
//        playerIcon.widthAnchor.constraint(equalToConstant: playerView.frame.height / 3).isActive = true
//        playerIcon.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 10).isActive = true
//        playerIcon.centerYAnchor.constraint(equalTo: playerView.centerYAnchor).isActive = true
//
//        let usernameAndVictoryCenterYConstant = playerUsernameLabel.frame.height / 2 - currentVictoryLabel.frame.height / 2 - 10
//        playerUsernameLabel.leftAnchor.constraint(equalTo: playerIcon.rightAnchor).isActive = true
//        playerUsernameLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
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
