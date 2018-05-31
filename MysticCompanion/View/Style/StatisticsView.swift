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
    
    /// Configures the StatisticsView with a specific user's statistics
    /// - parameter statistics: The specified user's statistics
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
            
            playerLabel.anchorTo(view,
                                 top: view.topAnchor,
                                 leading: view.leadingAnchor,
                                 trailing: view.trailingAnchor,
                                 padding: .init(top: 5, left: 5, bottom: 0, right: 5),
                                 size: .init(width: 0, height: 25))
            
            statisticsTable.anchorTo(view,
                                     top: playerLabel.bottomAnchor,
                                     bottom: doneButton.topAnchor,
                                     leading: view.leadingAnchor,
                                     trailing: view.trailingAnchor,
                                     padding: .init(top: 5, left: 5, bottom: 5, right: 5))
            
            doneButton.anchorTo(view,
                                bottom: view.bottomAnchor,
                                leading: view.leadingAnchor,
                                trailing: view.trailingAnchor,
                                size: .init(width: 0, height: 25))
            
            return view
        }()
        
        statisticsView.fillTo(self, padding: .init(top: 5, left: 5, bottom: 5, right: 5))
        setFrame()
    }
    
    /// Sets the frame of the StatisticsView so it follows these criteria:
    /// - The width is 20 points less than the screen's size
    /// - The height is 40 points less than the screen's size
    /// - The view is centered on the screen
    private func setFrame() {
        let widthMargin: CGFloat = 20.0
        let screenWidth = UIScreen.main.bounds.width
        let viewWidth = screenWidth - widthMargin
        
        let heightMargin: CGFloat = 50.0 + adBuffer
        let screenHeight = UIScreen.main.bounds.height
        let viewHeight = screenHeight - heightMargin
        
        self.frame = CGRect(x: widthMargin / 2, y: heightMargin / 2, width: viewWidth, height: viewHeight)
    }
}

extension StatisticsView {
    /// Fades the StatiticsView out and removes it from it's superview
    @objc func dismissStatisticsView(_ sender: UIButton) {
        print("LAYOUT: Done pressed...")
        self.fadeAlphaOut()
    }
}

//------------------------------------------
// MARK: - TableView DataSource and Delegate
//------------------------------------------
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
