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
    
    func configureCell(forPlayer player: Dictionary<String,AnyObject>, shouldDisplayStepper: Bool) {
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
        playerView.translatesAutoresizingMaskIntoConstraints = false
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = playerView.bounds
        blurEffectView.tag = 1001
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let playerIcon = CircleView()
        playerIcon.addBorder()
        playerIcon.addImage(deckImage, withWidthModifier: 10)
        playerIcon.backgroundColor = deckType?.color
        playerIcon.translatesAutoresizingMaskIntoConstraints = false

        let playerUsernameLabel = UILabel()
        playerUsernameLabel.font = UIFont(name: "\(fontFamily)-Bold", size: 20)
        playerUsernameLabel.textAlignment = .center
        playerUsernameLabel.text = username
        playerUsernameLabel.sizeToFit()
        playerUsernameLabel.tag = 3030
        playerUsernameLabel.translatesAutoresizingMaskIntoConstraints = false

        let currentVictoryLabel = UILabel()
        currentVictoryLabel.font = UIFont(name: fontFamily, size: 15)
        currentVictoryLabel.textAlignment = .center
        currentVictoryLabel.text = "\(currentVP + boxVP)"
        currentVictoryLabel.sizeToFit()
        currentVictoryLabel.translatesAutoresizingMaskIntoConstraints = false

        let deckVictoryStepper = GMStepper()
        deckVictoryStepper.tag = 4040
        deckVictoryStepper.labelFont = UIFont(name: fontFamily, size: 15)!
        deckVictoryStepper.buttonsBackgroundColor = theme.color
        deckVictoryStepper.labelBackgroundColor = theme.color4
        deckVictoryStepper.maximumValue = 500
        deckVictoryStepper.minimumValue = -500
        deckVictoryStepper.translatesAutoresizingMaskIntoConstraints = false
        
        let finishedImage = UIImageView()
        finishedImage.image = #imageLiteral(resourceName: "doneIcon")
        finishedImage.contentMode = .scaleAspectFit
        finishedImage.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(playerView)
        playerView.addSubview(blurEffectView)
        playerView.addSubview(playerIcon)
        playerView.addSubview(playerUsernameLabel)
        playerView.addSubview(currentVictoryLabel)

        playerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        playerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        playerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        playerIcon.centerXAnchor.constraint(equalTo: playerView.centerXAnchor).isActive = true
        playerIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        playerIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playerIcon.topAnchor.constraint(equalTo: playerView.topAnchor, constant: 5).isActive = true
        
        playerUsernameLabel.topAnchor.constraint(equalTo: playerIcon.bottomAnchor, constant: 5).isActive = true
        playerUsernameLabel.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 5).isActive = true
        playerUsernameLabel.rightAnchor.constraint(equalTo: playerView.rightAnchor, constant: -5).isActive = true
        
        currentVictoryLabel.topAnchor.constraint(equalTo: playerUsernameLabel.bottomAnchor, constant: 5).isActive = true
        currentVictoryLabel.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 5).isActive = true
        currentVictoryLabel.rightAnchor.constraint(equalTo: playerView.rightAnchor, constant: -5).isActive = true
        
        if username == Player.instance.username && shouldDisplayStepper {
            playerView.addSubview(deckVictoryStepper)
            
            deckVictoryStepper.heightAnchor.constraint(equalToConstant: 25).isActive = true
            deckVictoryStepper.widthAnchor.constraint(equalToConstant: 150).isActive = true
            deckVictoryStepper.centerXAnchor.constraint(equalTo: playerView.centerXAnchor).isActive = true
            deckVictoryStepper.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -5).isActive = true
        }
        
        if finished {
            playerView.addSubview(finishedImage)
            
            finishedImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
            finishedImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
            finishedImage.centerXAnchor.constraint(equalTo: playerView.centerXAnchor).isActive = true
            finishedImage.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -5).isActive = true
        }
    }
}
