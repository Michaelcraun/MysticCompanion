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
}

protocol Alertable {  }

extension Alertable where Self: UIViewController {
    func showAlert(withTitle title: String, andMessage message: String, andNotificationType type: NotificationType) {
        addBlurEffect()
        addVibration(withNotificationType: type)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            for subview in self.view.subviews {
                if subview.tag == 1001 {
                    subview.fadeAlphaOut()
                }
            }
            
            if alertController.message == "You ended the game. Please wait for the other players to complete their turns." {
                self.performSegue(withIdentifier: "showEndGame", sender: nil)
            }
        })
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithOptions(withTitle title: String, andMessage message: String, andNotificationType type: NotificationType) {
        addBlurEffect()
        addVibration(withNotificationType: type)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            for subview in self.view.subviews {
                if subview.tag == 1001 {
                    subview.fadeAlphaOut()
                }
            }
            
            if alertController.title == "Spoiled" {
                Player.instance.hasSpoiled = true
            }
        })
        let deny = UIAlertAction(title: "No", style: .default, handler: { action in
            for subview in self.view.subviews {
                if subview.tag == 1001 {
                    subview.fadeAlphaOut()
                }
            }
            
            if alertController.title == "Spoiled" {
                Player.instance.hasSpoiled = false
            }
        })
        
        alertController.addAction(confirm)
        alertController.addAction(deny)
        present(alertController, animated: true, completion: nil)
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.tag = 1001
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurEffectView)
    }
    
    func addVibration(withNotificationType type: NotificationType) {
        //TODO: Test
        switch UIDevice.current.notificationDevice {
        case .haptic:
            let notification = UINotificationFeedbackGenerator()
            switch type {
            case .endOfGame: notification.notificationOccurred(.warning)
            case .error: notification.notificationOccurred(.error)
            case .success: notification.notificationOccurred(.success)
            case .turnChange: notification.notificationOccurred(.warning)
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
