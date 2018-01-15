//
//  Alertable.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 12/5/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices

enum Alert {
    case credentialInUse
    case credentialMismatch
    case deckTaken
    case endOfGame
    case facebookError
    case emailAlreadyInUse
    case iapDisabled
    case invalidCredential
    case invalidEmail
    case invalidLogin
    case firebaseError
    case firebaseLogout
    case gameIsFull
    case googleSignIn
    case mailError
    case noConnection
    case notYourTurn
    case purchaseComplete
    case purchaseError
    case purchaseFailed
    case purchasesRestored
    case restoreFailed
    case unlockPremium
    case userExistsInGame
    case spoil
    case victoryChange
    case wrongPassword
    case yourTurn
    
    var title: String {
        switch self {
        case .credentialInUse: return Alert.firebaseError.title
        case .credentialMismatch: return Alert.firebaseError.title
        case .emailAlreadyInUse: return Alert.firebaseError.title
        case .endOfGame: return "End Of Game"
        case .facebookError: return "Facebook Error:"
        case .firebaseError: return "Firebase Error:"
        case .firebaseLogout: return Alert.firebaseError.title
        case .googleSignIn: return "Google Sign-In Error:"
        case .iapDisabled: return "In-App Purchases Disabled"
        case .invalidCredential: return Alert.firebaseError.title
        case .invalidEmail: return Alert.firebaseError.title
        case .noConnection: return "No Connection"
        case .purchaseComplete: return "Purchase Complete"
        case .purchaseFailed: return "Purchase Failed"
        case .purchasesRestored: return "Purchases Restored"
        case .spoil: return "Spoiled"
        case .unlockPremium: return "Unlock Premium"
        case .victoryChange: return "Victory Change"
        case .wrongPassword: return Alert.firebaseError.title
        case .yourTurn: return "Your Turn"
        default: return "Error:"
        }
    }
    
    var message: String {
        switch self {
        case .credentialInUse: return "That credential is already in use. Please try again."
        case .credentialMismatch: return "That account exists with a different credential. Please try again."
        case .deckTaken: return "That deck is already taken. Please choose a different one."
        case .emailAlreadyInUse: return "That email is already in use. Please try again."
        case .endOfGame: return "The game has concluded. Please enter the amount of victory points contained within your deck."
        case .facebookError: return "There was an unexpected error when attempting to sign in with Facebook. Please try again."
        case .firebaseLogout: return "There was an unexpected error logging out. Please try again."
        case .gameIsFull: return "That game is full. Please select a different game."
        case .googleSignIn: return "There was an unexpected error when attempting to sign in with Google. Please try again."
        case .iapDisabled: return "Please enable in-app purchases to access the full features of this app."
        case .invalidCredential: return "That credential is invalid. Please try again."
        case .invalidEmail: return "That is an invalid email. Please try again."
        case .invalidLogin: return "Please provide a username, valid email, and password!"
        case .mailError: return "Your device is not able to send email."
        case .noConnection: return "MysticCompanion requires an internet connection to track your games. Please try again when you have a connection."
        case .notYourTurn: return "It is not your turn. Please wait for other players."
        case .purchaseComplete: return "Thank you for purchasing!"
        case .purchaseError: return "Cannot currently complete your request. Please try again later."
        case .purchaseFailed: return "Please try again or contact support."
        case .purchasesRestored: return "Your purchases have been restored. Thank you."
        case .restoreFailed: return "Your purchases failed to be restored. Please try again."
        case .spoil: return "According to the rules of the game, you've spoiled. Is this true? \nIf you tap Yes, you will gain no VP this turn and play will pass to the next player when you end your turn."
        case .unlockPremium: return "You have not yet purchase premium features. Would you like to unlock premium features so you can start a custom game?"
        case .userExistsInGame: return "You're already in that game!"
        case .victoryChange: return "Please input your change to victory below:"
        case .wrongPassword: return "The email or password you have entered is incorrect. Please try again."
        case .yourTurn: return "It is your turn. Please continue."
        default: return "An unexpected error occured. Please try again."
        }
    }
    
    var notificationType: NotificationType {
        switch self {
        case .endOfGame: return .endOfGame
        case .noConnection: return .error
        case .purchaseComplete: return .success
        case .purchasesRestored: return .success
        case .victoryChange: return .warning
        case .yourTurn: return .turnChange
        default: return .error
        }
    }
    
    var needsOptions: Bool {
        switch self {
        case .spoil: return true
        case .unlockPremium: return true
        default: return false
        }
    }
    
    var needsTextFields: Bool {
        switch self {
        case .victoryChange: return true
        default: return false
        }
    }
}
enum NotificationType {
    case endOfGame
    case error
    case success
    case turnChange
    case warning
}

protocol Alertable {  }

extension Alertable where Self: UIViewController {
    func showAlert(_ alert: Alert) {
        var defaultActionTitle: String {
            switch alert.needsOptions {
            case true: return "No"
            case false: return "OK"
            }
        }
        
        view.addBlurEffect()
        addVibration(withNotificationType: alert.notificationType)
        
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: defaultActionTitle, style: .default) { (action) in
            self.dismissAlert()
            
            if alert.needsTextFields {
                if let vpToPool = alertController.textFields![0].text {
                    if vpToPool != "" {
                        guard let gameKey = GameHandler.instance.game["game"] as? String else { return }
                        guard let currentVPGoal = GameHandler.instance.game["vpGoal"] as? Int else { return }
                        let numVPToPool = Int(vpToPool)!
                        let newVPGoal = currentVPGoal + numVPToPool
                        GameHandler.instance.game["vpGoal"] = newVPGoal as AnyObject
                        
                        GameHandler.instance.updateFirebaseDBGame(key: gameKey, gameData: GameHandler.instance.game)
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
            }
        }
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            self.dismissAlert()
            
            if alertController.title == "Spoiled" {
                if let gameVC = self as? GameVC {
                    gameVC.userHasSpoiled = true
                }
            }
            
            if alertController.title == "Unlock Premium" {
                self.performSegue(withIdentifier: "showSettings", sender: nil)
            }
        }
        
        if alert.needsTextFields {
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
        }
        
        alertController.addAction(defaultAction)
        if alert.needsOptions {
            alertController.addAction(yesAction)
        }
        
        present(alertController, animated: false, completion: nil)
    }
    
    func dismissAlert() {
        for subview in self.view.subviews {
            if subview.tag == 1001 {
                subview.fadeAlphaOut()
            }
        }
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
