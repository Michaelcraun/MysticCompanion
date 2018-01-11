//
//  Alertable.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 12/5/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices

enum NotificationType {
    case endOfGame
    case error
    case success
    case turnChange
    case warning
}

protocol Alertable {  }

extension Alertable where Self: UIViewController {
    func showAlert(withTitle title: String, andMessage message: String, andNotificationType type: NotificationType) {
        view.addBlurEffect()
        addVibration(withNotificationType: type)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            for subview in self.view.subviews {
                if subview.tag == 1001 {
                    subview.fadeAlphaOut()
                }
            }
        })
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithOptions(withTitle title: String, andMessage message: String, andNotificationType type: NotificationType) {
        view.addBlurEffect()
        addVibration(withNotificationType: type)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            for subview in self.view.subviews {
                if subview.tag == 1001 {
                    subview.fadeAlphaOut()
                }
            }
            
            if alertController.title == "Spoiled" {
                if let gameVC = self as? GameVC {
                    gameVC.userHasSpoiled = true
                }
            }
        })
        let deny = UIAlertAction(title: "No", style: .default, handler: { action in
            for subview in self.view.subviews {
                if subview.tag == 1001 {
                    subview.fadeAlphaOut()
                }
            }
        })
        
        alertController.addAction(confirm)
        alertController.addAction(deny)
        present(alertController, animated: true, completion: nil)
    }
    
    func showVPAlert(withGame game: Dictionary<String,AnyObject>) {
        view.addBlurEffect()
        addVibration(withNotificationType: .warning)
        
        let alertController = UIAlertController(title: "Victory Change", message: "Please input your change to victory below:", preferredStyle: .alert)
        alertController.addTextField { (vpToPool) in
            vpToPool.font = UIFont(name: fontFamily, size: 15)
            vpToPool.keyboardType = .numberPad
            vpToPool.textAlignment = .center
            vpToPool.placeholder = "Add Victory to the Pool"
        }
        
        alertController.addTextField { (vpFromBox) in
            vpFromBox.font = UIFont(name: fontFamily, size: 15)
            vpFromBox.keyboardType = .numberPad
            vpFromBox.textAlignment = .center
            vpFromBox.placeholder = "Add Victory to Your Pool"
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let vpToPool = alertController.textFields![0].text {
                if vpToPool != "" {
                    guard let gameKey = game["game"] as? String else { return }
                    guard let currentVPGoal = game["vpGoal"] as? Int else { return }
                    let numVPToPool = Int(vpToPool)!
                    let newVPGoal = currentVPGoal + numVPToPool
                    var newGameData = game
                    newGameData["vpGoal"] = newVPGoal as AnyObject
                    
                    GameHandler.instance.updateFirebaseDBGame(key: gameKey, gameData: newGameData)
                }
            }
            
            if let vpFromBox = alertController.textFields![1].text {
                if vpFromBox != "" {
                    let numVPFromBox = Int(vpFromBox)!
                    Player.instance.boxVP += numVPFromBox
                }
            }
            
            for subview in self.view.subviews {
                if subview.tag == 1001 {
                    subview.fadeAlphaOut()
                }
            }
        }))
        
        present(alertController, animated: false, completion: nil)
    }
    
    func addVibration(withNotificationType type: NotificationType) {
        switch UIDevice.current.notificationDevice {
        case .haptic:
            let notification = UINotificationFeedbackGenerator()
            switch type {
            case .endOfGame: notification.notificationOccurred(.warning)
            case .error: notification.notificationOccurred(.error)
            case .success: notification.notificationOccurred(.success)
            case .turnChange: notification.notificationOccurred(.warning)
            case .warning: notification.notificationOccurred(.warning)
            }
        case .vibrate:
            let vibrate = SystemSoundID(kSystemSoundID_Vibrate)
            switch type {
            case .turnChange: AudioServicesPlaySystemSound(vibrate)
            default: break
            }
        default: break
        }
    }
}
