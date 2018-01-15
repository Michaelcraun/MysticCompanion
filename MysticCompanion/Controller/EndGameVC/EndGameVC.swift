//
//  EndGameVC.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import GoogleMobileAds
import KCFloatingActionButton
import GMStepper
import Firebase
import FirebaseAuth

class EndGameVC: UIViewController, Alertable, Connection {
    //MARK: Game Variables
    enum GameState {
        case vpNeeded
        case vpSubmitted
        case gameFinalized
    }
    
    var gameState: GameState = .vpNeeded {
        didSet {
            switch gameState {
            case .vpNeeded: shouldDisplayStepper = true
            case .vpSubmitted: shouldDisplayStepper = false
            case .gameFinalized: shouldDisplayStepper = false
            }
        }
    }
    
    //MARK: Firebase Variables
    var players = [Dictionary<String,AnyObject>]() {
        didSet {
            playersTable.animate()
        }
    }
    
    //MARK: UI Variables
    let playersTable = UITableView()
    let adBanner = GADBannerView()
    let menuButton = KCFloatingActionButton()
    var shouldDisplayStepper = true
    var winnersArray = [String]()
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGameAndObserve()
        layoutView()
        beginConnectionTest()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showAlert(.endOfGame)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton(gameState: gameState)
        beginConnectionTest()
    }
    
    func donePressed() {
        let stepper = self.view.viewWithTag(4040) as! GMStepper
        let deckVP = Int(stepper.value)
        
        updateUser(Player.instance.username, withDeckVP: deckVP)
        playersTable.animate()
        layoutMenuButton(gameState: .vpSubmitted)
    }
    
    func quitPressed() {
        GameHandler.instance.REF_GAME.removeAllObservers()
        
        Player.instance.hasQuitGame = true
        //TODO: Prepare HomeVC for end of game animation
        dismissPreviousViewControllers()
    }
    
    func sharePressed() {
        var isWinner: Bool {
            var _isWinner = false
            for winner in winnersArray {
                if winner == Player.instance.username {
                    _isWinner = true
                    break
                }
            }
            return _isWinner
        }
        
        var shareMessage: String {
            switch isWinner {
            case true: return "I just won a game of Mystic Vale with my friends using #MysticCompanion. You should come play with us!"
            case false: return "I just played a game of Mystic Vale with my friends using #MysticCompanion. You should come play with us!"
            }
        }
        let shareURL = "https://itunes.apple.com/us/app/mysticcompanion/id1249561021?mt=8"
        
        let activityVC = UIActivityViewController(activityItems: [shareURL, shareMessage], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        present(activityVC, animated: true, completion: nil)
    }
    
    func animateWinner(_ cell: UITableViewCell) {
        let winnerHeight = cell.frame.height / 2
        let winnerWidth = cell.frame.width
        
        let winnerImage = UIImageView()
        winnerImage.contentMode = .scaleAspectFit
        winnerImage.image = #imageLiteral(resourceName: "winner")
        winnerImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(winnerImage)
        
        winnerImage.heightAnchor.constraint(equalToConstant: winnerHeight).isActive = true
        winnerImage.widthAnchor.constraint(equalToConstant: winnerWidth).isActive = true
        winnerImage.rightAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        winnerImage.topAnchor.constraint(equalTo: cell.topAnchor, constant: cell.frame.height / 2 - winnerImage.frame.height / 2).isActive = true
        
        UIView.animate(withDuration: 0.5) {
            winnerImage.frame.origin.x += winnerWidth
        }
    }
}
