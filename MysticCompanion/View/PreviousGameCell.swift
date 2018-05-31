//
//  PreviousGameCell.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class PreviousGameCell: UITableViewCell {
    let playersTable = UITableView()
    var playersArray = [[String : AnyObject]]()
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
    
    /// Configures the cell to display the results of a previous game
    /// - parameter players: An Array of Dictionary values containing the specified game
    /// - parameter winners: An Array of String values contaning the usernames of the winner(s) of the specified game
    func layoutGame(withPlayers players: [[String : AnyObject]], andWinners winners: [String]) {
        clearCell()
        self.addBlurEffect()
        
        self.playersArray = players
        self.winners = winners
        
        playersTable.backgroundColor = .clear
        playersTable.separatorStyle = .none
        playersTable.allowsSelection = false
        playersTable.register(PreviousGamePlayersCell.self, forCellReuseIdentifier: "previousGamePlayersCell")
        playersTable.fillTo(self, padding: .init(top: 5, left: 5, bottom: 5, right: 5))
        self.updateConstraints()
    }
    
    /// Configures the cell to display to the user that no games were found on Firebase
    func layoutEmptyCell() {
        clearCell()
        addBlurEffect()
        self.backgroundColor = theme.color
        
        let noGamesLabel = UILabel()
        noGamesLabel.font = UIFont(name: fontFamily, size: 20)
        noGamesLabel.textAlignment = .center
        noGamesLabel.text = "No Games Found"
        noGamesLabel.anchorTo(self,
                              leading: self.leadingAnchor,
                              trailing: self.trailingAnchor,
                              centerY: self.centerYAnchor,
                              padding: .init(top: 0, left: 20, bottom: 0, right: 20))
    }
}

//------------------------------------------
// MARK: - TableView DataSource and Delegate
//------------------------------------------
extension PreviousGameCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousGamePlayersCell") as! PreviousGamePlayersCell
        let playerToDisplay = playersArray[indexPath.row]
        cell.layoutCell(forPlayer: playerToDisplay, withWinners: winners)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 27.33
    }
}
