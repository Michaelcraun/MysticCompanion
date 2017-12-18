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
    
    func clearCell() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func configureCell(forPlayer player: Dictionary<String,AnyObject>, shouldDisplayStepper: Bool) {
        print(player)
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
        playerView.layer.cornerRadius = 10
        playerView.layer.borderColor = UIColor.black.cgColor
        playerView.layer.borderWidth = 2
        playerView.backgroundColor = deckType?.secondaryColor
        playerView.translatesAutoresizingMaskIntoConstraints = false
        
        let playerInfoStack = UIStackView()
        playerInfoStack.alignment = .center
        playerInfoStack.axis = .vertical
        playerInfoStack.distribution = .equalSpacing
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
        deckVictoryStepper.tag = 4040
        deckVictoryStepper.buttonsBackgroundColor = theme.color
        deckVictoryStepper.labelBackgroundColor = theme.color4
        deckVictoryStepper.maximumValue = 500
        deckVictoryStepper.minimumValue = -500
        deckVictoryStepper.translatesAutoresizingMaskIntoConstraints = false
        
        let finishedImage = UIImageView()
        finishedImage.image = #imageLiteral(resourceName: "doneIcon")
        finishedImage.contentMode = .scaleAspectFit
        finishedImage.translatesAutoresizingMaskIntoConstraints = false
        
        playerInfoStack.addArrangedSubview(playerIcon)
        playerInfoStack.addArrangedSubview(playerUsernameLabel)
        playerInfoStack.addArrangedSubview(currentVictoryLabel)
        if username == Player.instance.username && shouldDisplayStepper {
            playerInfoStack.addArrangedSubview(deckVictoryStepper)
        }
        
        if finished {
            playerInfoStack.addArrangedSubview(finishedImage)
        }

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
    }
}
