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
    var playersArrayForCell = [Dictionary<String,AnyObject>]()
//    {
//        didSet {
//            playersTable.reloadData()
//        }
//    }
    
    override func layoutSubviews() {
        print("BRETT: In layoutSubviews")
        super.layoutSubviews()
        
        self.layer.cornerRadius = 15
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
        
        playersTable.dataSource = self
        playersTable.delegate = self
    }
    
    func layoutGame(game: Dictionary<String,AnyObject>) {
        print("BRETT: In layoutGame.")
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
            print("BRETT: Data Append")
        }
        
        playersTable.separatorStyle = .none
        playersTable.backgroundColor = .clear
        playersTable.register(PlayersTableCell.self, forCellReuseIdentifier: "previousGamePlayersTableCell")
        playersTable.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(playersTable)
        
        playersTable.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        playersTable.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        playersTable.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        playersTable.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
    }
    
    func layoutEmptyCell() {
        print("BRETT: layoutEmptyCell.")
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("BRETT: In heightForRow")
        return 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("BRETT: \(tableView)")
        print(playersArrayForCell.count)
        return playersArrayForCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "previousGamePlayersTableCell") as! PlayersTableCell
        print("BRETT: \(playersArrayForCell[indexPath.row])")
//        cell.layoutCell(forPlayer: playersArrayForCell[indexPath.row])
        let cell = UITableViewCell()
        return cell
    }
}
