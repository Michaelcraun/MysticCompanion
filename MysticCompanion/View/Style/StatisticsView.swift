//
//  StatisticsView.swift
//  MysticCompanion
//
//  Created by Michael Craun on 4/12/18.
//  Copyright © 2018 Craunic Productions. All rights reserved.
//

import UIKit

class StatisticsView: UIView {
    var statistics = [String : AnyObject]()
    var statisticsView = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func layoutWithStatistics(_ statistics: [String : AnyObject]) {
        self.statistics = statistics
        
        statisticsView = {
            let view = UIView()
            view.addBlurEffect()
            view.clipsToBounds = true
            view.layer.cornerRadius = 10
            view.layer.borderColor = UIColor.black.cgColor
            view.layer.borderWidth = 2
            
            let playerLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont(name: "\(fontFamily)-Bold", size: 20)
                label.text = statistics["username"] as? String ?? ""
                label.textAlignment = .center
                return label
            }()
            
            let statisticsTable: UITableView = {
                let tableView = UITableView()
                tableView.backgroundColor = .clear
                tableView.dataSource = self
                tableView.delegate = self
                tableView.register(StatisticsCell.self, forCellReuseIdentifier: "statisticsCell")
                tableView.separatorStyle = .none
                return tableView
            }()
            
            let doneButton: UIButton = {
                let button = UIButton()
                button.addTarget(self, action: #selector(dismissStatisticsView(_:)), for: .touchUpInside)
                button.backgroundColor = .black
                button.setTitle("Done", for: .normal)
                button.titleLabel?.font = UIFont(name: fontFamily, size: 15)
                button.titleLabel?.textColor = .darkText
                return button
            }()
            
            let viewElements = [playerLabel, statisticsTable, doneButton]
            viewElements.forEach({ (element) in view.addSubview(element) })
            
            playerLabel.translatesAutoresizingMaskIntoConstraints = false
            playerLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
            playerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
            playerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
            playerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
            
            statisticsTable.translatesAutoresizingMaskIntoConstraints = false
            statisticsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
            statisticsTable.topAnchor.constraint(equalTo: playerLabel.bottomAnchor, constant: 5).isActive = true
            statisticsTable.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -5).isActive = true
            statisticsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
            
            doneButton.translatesAutoresizingMaskIntoConstraints = false
            doneButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            
            return view
        }()
        
        self.addSubview(statisticsView)
        statisticsView.translatesAutoresizingMaskIntoConstraints = false
        statisticsView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        statisticsView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        statisticsView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        statisticsView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        
        setFrame()
    }
    
    private func setFrame() {
        let widthMargin: CGFloat = 20.0
        let screenWidth = UIScreen.main.bounds.width
        let viewWidth = screenWidth - widthMargin
        
        let heightMargin: CGFloat = 40.0
        let screenHeight = UIScreen.main.bounds.height
        let viewHeight = screenHeight - heightMargin
        
        self.frame = CGRect(x: widthMargin / 2, y: heightMargin / 2, width: viewWidth, height: viewHeight)
    }
}

extension StatisticsView {
    @objc func dismissStatisticsView(_ sender: UIButton) {
        print("LAYOUT: Done pressed...")
        self.fadeAlphaOut()
    }
}

extension StatisticsView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statisticsCell") as! StatisticsCell
        switch indexPath.row {
        case 0: cell.layoutCellForStatistic("Win Percentage", withValue: statistics["winPercentage"])
        case 1: cell.layoutCellForStatistic("Games Played", withValue: statistics["gamesPlayed"])
        case 2: cell.layoutCellForStatistic("Games Won", withValue: statistics["gamesWon"])
        case 3: cell.layoutCellForStatistic("GamesLost", withValue: statistics["gamesLost"])
        case 4: cell.layoutCellForStatistic("Most Mana Gained In One Turn", withValue: statistics["mostManaGainedInOneTurn"])
        case 5: cell.layoutCellForStatistic("Most VP Gained In One Turn", withValue: statistics["mostVPGainedInOneTurn"])
        case 6: cell.layoutCellForStatistic("Most VP Gained In One Game", withValue: statistics["mostVPGainedInOneGame"])
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
