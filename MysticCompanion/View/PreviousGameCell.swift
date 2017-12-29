//
//  PreviousGameCell.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class PreviousGameCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    let playersTable = UITableView()
    var playersArrayForCell = [Dictionary<String,AnyObject>]() {
        didSet {
            playersTable.reloadData()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 15
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
    }
    
    func layoutGame(game: Dictionary<String,AnyObject>) {
        print("game found...")
        playersArrayForCell = []
        guard let playersArray = game["players"] as? [Dictionary<String,AnyObject>] else { return }
        
        for player in playersArray {
            guard let playerUsername = player["username"] as? String else { return }
            guard let victoryPoints = player["victoryPoints"] as? Int else { return }
            guard let boxVictory = player["boxVictory"] as? Int else { return }
            let totalVP = victoryPoints + boxVictory
            let playerData: Dictionary<String,AnyObject> = ["username" : playerUsername as AnyObject,
                                                            "victoryPoints" : totalVP as AnyObject]
            playersArrayForCell.append(playerData)
        }
        
        playersTable.dataSource = self
        playersTable.delegate = self
        playersTable.separatorStyle = .none
        playersTable.backgroundColor = .clear
        playersTable.register(PlayersTableCell.self, forCellReuseIdentifier: "playersTableCell")
        playersTable.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(playersTable)
        
        playersTable.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        playersTable.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        playersTable.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        playersTable.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
    }
    
    func layoutEmptyCell() {
        let noGamesLabel = UILabel()
        noGamesLabel.font = UIFont(name: fontFamily, size: 20)
        noGamesLabel.textAlignment = .center
        noGamesLabel.text = "No Games Found"
        noGamesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = theme.color
        self.addSubview(noGamesLabel)
        
        noGamesLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        noGamesLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        noGamesLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersArrayForCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playersTableCell") as! PlayersTableCell
        print(playersArrayForCell[indexPath.row])
        cell.layoutCell(forPlayer: playersArrayForCell[indexPath.row])
        return cell
    }
}
