//
//  HomeFirebase.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/27/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation

extension HomeVC {
    func checkUserID() {
        let defaults = UserDefaults.standard
        let userID = defaults.string(forKey: "userID")
        if userID != nil {
            //TODO: Load user data
            let userName = defaults.string(forKey: "userName")
            playerName.text = userName
        } else {
            //TODO: Ask user to sign in to Firebase
            playerName.text = generateID()
        }
    }
    
    func generateID() -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var userID = "user"
        
        for _ in 0..<10 {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            userID += String(newCharacter)
        }
        return userID
    }
    
//    @objc func register(sender: UIButton!) {
//        self.view.endEditing(true)
//        if let email = emailField.text, let password = passwordField.text {
//            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
//                if error == nil {
//                    self.presentFirebaseAlert(withSuccess: true, andMessage: "Successfully logged in user \(email)! Thank you!")
//                    if let user = user {
//                        let userData = ["provider" : user.providerID] as [String : Any]
//                        self.defaults.set(user.uid, forKey: "userID")                         //DISABLED FOR TESTING!
//                        GameHandler.sharedInstance.createFirebaseDBUser(uid: user.uid, userData: userData)
//                        GameHandler.sharedInstance.loadGameStats()
//                    }
//                } else {
//                    if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
//                        switch errorCode {
//                        case .errorCodeInvalidEmail: self.presentFirebaseAlert(withSuccess: false, andMessage: "Invalid email. Try again?")
//                        case .errorCodeWrongPassword: self.presentFirebaseAlert(withSuccess: false, andMessage: "Wrong password. Try again?")
//                        default: self.presentFirebaseAlert(withSuccess: false, andMessage: "Unexpected error. Try again?")
//                        }
//                    }
//                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
//                        if error != nil {
//                            if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
//                                switch errorCode {
//                                case .errorCodeInvalidEmail: self.presentFirebaseAlert(withSuccess: false, andMessage: "Invalid email. Try again?")
//                                case .errorCodeEmailAlreadyInUse: self.presentFirebaseAlert(withSuccess: false, andMessage: "Email alread in use. Try again?")
//                                default: self.presentFirebaseAlert(withSuccess: false, andMessage: "Unexpected error. Try again?")
//                                }
//                            }
//                        } else {
//                            self.presentFirebaseAlert(withSuccess: true, andMessage: "Successfully created user \(email)! Thank you!")
//                            if let user = user {
//                                let userData = ["provider" : user.providerID] as [String : Any]
//                                self.defaults.set(user.uid, forKey: "userID")
//                                GameHandler.sharedInstance.createFirebaseDBUser(uid: user.uid, userData: userData)
//                                GameHandler.sharedInstance.initializeFireBase()
//                                GameHandler.sharedInstance.loadGameStats()
//                            }
//                        }
//                    })
//                }
//            })
//        }
//    }
//
//    func presentFirebaseAlert(withSuccess success: Bool, andMessage message: String) {
//        var _success: String {
//            switch success {
//            case true: return "Success"
//            case false: return "Error"
//            }
//        }
//
//        let alert = UIAlertController(title: "Firebase \(_success)!", message: message, preferredStyle: .alert)
//        if success {
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
//                self.loadGame(sender: nil)
//            }))
//        } else {
//            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
//            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
//                self.loadGame(sender: nil)
//            }))
//        }
//        present(alert, animated: true, completion: nil)
//    }
}
