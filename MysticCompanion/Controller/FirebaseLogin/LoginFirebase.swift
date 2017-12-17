//
//  LoginFirebase.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/6/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import Firebase

extension LoginVC: Alertable {
    func loginWithFirebase() {
        if usernameField.text != "" && emailField.text != "" && passwordField.text != "" {
            view.endEditing(true)
            if let username = usernameField.text, let email = emailField.text, let password = passwordField.text {
                FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error == nil {
                        if let user = user {
                            let userData = ["provider" : user.providerID,
                                            "username" : username]
                            GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                        }
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let alertTitle = "Firebase Error:"
                        if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
                            switch errorCode {
                            case .errorCodeEmailAlreadyInUse: self.showAlert(withTitle: alertTitle, andMessage: "That email is already in use. Pleas try again.", andNotificationType: .error)
                            case .errorCodeWrongPassword: self.showAlert(withTitle: alertTitle, andMessage: "That email is already in use. Please try again.", andNotificationType: .error)
                            case .errorCodeInvalidEmail: self.showAlert(withTitle: alertTitle, andMessage: "That is an invalid email. Please try again.", andNotificationType: .error)
                            case .errorCodeUserNotFound:
                                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                                    if error != nil {
                                        if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
                                            switch errorCode {
                                            case .errorCodeInvalidEmail: self.showAlert(withTitle: alertTitle, andMessage: "That is an invalid email. Please try again.", andNotificationType: .error)
                                            default: self.showAlert(withTitle: alertTitle, andMessage: "There was an unexpected error. Please try again.", andNotificationType: .error)
                                            }
                                        }
                                    } else {
                                        if let user = user {
                                            let userData = ["provider" : user.providerID,
                                                            "username" : username]
                                            GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                                        }
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                })
                            default: self.showAlert(withTitle: alertTitle, andMessage: "There was an unexpected error. Please try again.", andNotificationType: .error)
                            }
                        }
                    }
                })
            }
        } else {
            showAlert(withTitle: "Error:", andMessage: "Please provide a username, valid email, and password!", andNotificationType: .error)
        }
    }
}
