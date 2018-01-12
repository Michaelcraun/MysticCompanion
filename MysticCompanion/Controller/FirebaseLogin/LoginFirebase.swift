//
//  LoginFirebase.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/6/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

import GoogleSignIn

extension LoginVC: Alertable {
    func loginWithFirebase() {
        if usernameField.text != "" && emailField.text != "" && passwordField.text != "" {
            view.endEditing(true)
            guard let username = usernameField.text, let email = emailField.text, let password = passwordField.text else { return }
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    guard let user = user else { return }
                    let userData: Dictionary<String,Any> = ["provider" : user.providerID,
                                                            "username" : username,
                                                            "mostManaGainedInOneTurn" : 0,
                                                            "mostVPGainedInOneTurn" : 0,
                                                            "gamesPlayed" : 0,
                                                            "gamesWon" : 0,
                                                            "gamesLost" : 0,
                                                            "mostVPGainedInOneGame" : 0]
                    GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    guard let errorCode = FIRAuthErrorCode(rawValue: error!._code) else { return }
                    switch errorCode {
                    case .errorCodeEmailAlreadyInUse: self.showAlert(.emailAlreadyInUse)
                    case .errorCodeWrongPassword: self.showAlert(.wrongPassword)
                    case .errorCodeInvalidEmail: self.showAlert(.invalidEmail)
                    case .errorCodeUserNotFound:
                        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                guard let errorCode = FIRAuthErrorCode(rawValue: error!._code) else { return }
                                switch errorCode {
                                case .errorCodeInvalidEmail: self.showAlert(.invalidEmail)
                                default: self.showAlert(.firebaseError)
                                }
                            } else {
                                guard let user = user else { return }
                                let userData: Dictionary<String,Any> = ["provider" : user.providerID,
                                                                        "username" : username,
                                                                        "mostManaGainedInOneTurn" : 0,
                                                                        "mostVPGainedInOneTurn" : 0,
                                                                        "gamesPlayed" : 0,
                                                                        "gamesWon" : 0,
                                                                        "gamesLost" : 0,
                                                                        "mostVPGainedInOneGame" : 0]
                                GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    default: self.showAlert(.firebaseError)
                    }
                }
            })
        } else {
            showAlert(.invalidLogin)
        }
    }
    
    func login(withCredential credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if let error = error {
                guard let errorCode = FIRAuthErrorCode(rawValue: error._code) else { return }
                switch errorCode {
                case .errorCodeCredentialAlreadyInUse: self.showAlert(.credentialInUse)
                case .errorCodeAccountExistsWithDifferentCredential: self.showAlert(.credentialMismatch)
                case .errorCodeInvalidCredential: self.showAlert(.invalidCredential)
                default: self.showAlert(.firebaseError)
                }
                return
            }
            
            guard let user = user else { return }
            let userData: Dictionary<String,Any> = ["provider" : user.providerID,
                                                    "username" : user.displayName as Any,
                                                    "mostManaGainedInOneTurn" : 0,
                                                    "mostVPGainedInOneTurn" : 0,
                                                    "gamesPlayed" : 0,
                                                    "gamesWon" : 0,
                                                    "gamesLost" : 0,
                                                    "mostVPGainedInOneGame" : 0]
            GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
            self.dismiss(animated: true, completion: nil)
        })
    }
}
