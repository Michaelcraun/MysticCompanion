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
        if usernameField.text != nil && emailField.text != nil && passwordField.text != nil {
            view.endEditing(true)
            if let username = usernameField.text, let email = emailField.text, let password = passwordField.text {
                FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error == nil {
                        if let user = user {
                            let userData = ["provider" : user.providerID,
                                            "username" : username,
                                            "isLookingForGame" : false,
                                            "isHostingGame" : false] as [String : Any]
                            GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                        }
                        print("email user successfully authenticated with firebase.")
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
                            switch errorCode {
                            case .errorCodeEmailAlreadyInUse: self.showAlert("That email is already in use. Pleas try again.")
                            case .errorCodeWrongPassword: self.showAlert("That is the wrong password. Please try again.")
                            case .errorCodeInvalidEmail: self.showAlert("That is an invalid email. Please try again.")
                            case .errorCodeUserNotFound:
                                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                                    if error != nil {
                                        if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
                                            switch errorCode {
                                            case .errorCodeInvalidEmail: self.showAlert("That is an invalid email. Please try again.")
                                            default: self.showAlert("There was an unexpected error. Please try again.")
                                            }
                                        }
                                    } else {
                                        if let user = user {
                                            let userData = ["provider" : user.providerID,
                                                            "username" : username,
                                                            "isLookingForGame" : false,
                                                            "isHostingGame" : false] as [String : Any]
                                            GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
                                        }
                                        print("successfully created a new firebase user.")
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                })
                            default: self.showAlert("There was an unexpected error. Please try again.")
                            }
                        }
                    }
                })
            }
        }
    }
}
