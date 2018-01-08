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
    var playersArray = [Dictionary<String,AnyObject>]()
    var winners = [String]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 15
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
        self.backgroundColor = .clear
        self.clipsToBounds = true
        
        playersTable.dataSource = self
        playersTable.delegate = self
    }
    
    func layoutGame(game: Dictionary<String,AnyObject>) {
        clearCell()
        self.addBlurEffect()
        
        guard let playersArray = game["players"] as? [Dictionary<String,AnyObject>] else { return }
        guard let winners = game["winners"] as? [String] else { return }
        
         self.playersArray = playersArray
        self.winners = winners
        
        playersTable.backgroundColor = .clear
        playersTable.separatorStyle = .none
        playersTable.allowsSelection = false
        playersTable.register(PreviousGamePlayersCell.self, forCellReuseIdentifier: "previousGamePlayersCell")
        playersTable.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(playersTable)
        
        playersTable.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        playersTable.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        playersTable.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        playersTable.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
    }
    
    func layoutEmptyCell() {
        clearCell()
        
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
        return playersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousGamePlayersCell") as! PreviousGamePlayersCell
        cell.layoutCell(forPlayer: playersArray[indexPath.row], withWinners: winners)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 27.33
    }
}
