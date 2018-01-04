//
//  LoginFirebase.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/6/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

extension LoginVC: Alertable {
    func loginWithFirebase() {
        if usernameField.text != "" && emailField.text != "" && passwordField.text != "" {
            view.endEditing(true)
            guard let username = usernameField.text, let email = emailField.text, let password = passwordField.text else { return }
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    guard let user = user else { return }
                    let userData = ["provider" : user.providerID,
                                    "username" : username]
                    GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let alertTitle = "Firebase Error:"
                    guard let errorCode = FIRAuthErrorCode(rawValue: error!._code) else { return }
                    switch errorCode {
                    case .errorCodeEmailAlreadyInUse: self.showAlert(withTitle: alertTitle, andMessage: "That email is already in use. Pleas try again.", andNotificationType: .error)
                    case .errorCodeWrongPassword: self.showAlert(withTitle: alertTitle, andMessage: "That email is already in use. Please try again.", andNotificationType: .error)
                    case .errorCodeInvalidEmail: self.showAlert(withTitle: alertTitle, andMessage: "That is an invalid email. Please try again.", andNotificationType: .error)
                    case .errorCodeUserNotFound:
                        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                guard let errorCode = FIRAuthErrorCode(rawValue: error!._code) else { return }
                                switch errorCode {
                                case .errorCodeInvalidEmail: self.showAlert(withTitle: alertTitle, andMessage: "That is an invalid email. Please try again.", andNotificationType: .error)
                                default: self.showAlert(withTitle: alertTitle, andMessage: "There was an unexpected error. Please try again.", andNotificationType: .error)
                                }
                            } else {
                                guard let user = user else { return }
                                let userData = ["provider" : user.providerID,
                                                "username" : username]
                                GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    default: self.showAlert(withTitle: alertTitle, andMessage: "There was an unexpected error. Please try again.", andNotificationType: .error)
                    }
                }
            })
        } else {
            showAlert(withTitle: "Error:", andMessage: "Please provide a username, valid email, and password!", andNotificationType: .error)
        }
    }
    
    func login(withCredential credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if let error = error {
                print("there was an error logging into Firebase: ", error)
                let alertTitle = "Firebase Error:"
                guard let errorCode = FIRAuthErrorCode(rawValue: error._code) else { return }
                switch errorCode {
                case .errorCodeCredentialAlreadyInUse: self.showAlert(withTitle: alertTitle, andMessage: "That credential is already in use. Please try again.", andNotificationType: .error)
                case .errorCodeAccountExistsWithDifferentCredential: self.showAlert(withTitle: alertTitle, andMessage: "That account exists with a different credential. Please try again.", andNotificationType: .error)
                case .errorCodeInvalidCredential: self.showAlert(withTitle: alertTitle, andMessage: "That credential is invalid. Please try again.", andNotificationType: .error)
                default: self.showAlert(withTitle: alertTitle, andMessage: "There was an unexpected error. Please try again.", andNotificationType: .error)
                }
                return
            }
            
            guard let user = user else { return }
            let userData = ["provider" : user.providerID,
                            "username" : user.displayName as Any]
            GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
            self.dismiss(animated: true, completion: nil)
        })
    }
}
