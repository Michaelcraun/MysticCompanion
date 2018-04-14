//
//  FirebaseLoginVC.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

import TextFieldEffects
import KCFloatingActionButton

import Firebase
import FirebaseAuth

import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit

class LoginVC: UIViewController, UITextFieldDelegate, Connection, GIDSignInDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    let backgroundImage = UIImageView()
    let logoStack = UIStackView()
    let usernameField = KaedeTextField()
    let emailField = KaedeTextField()
    let passwordField = KaedeTextField()
    var facebookLogin = FBSDKLoginButton()
    var googleLogin = GIDSignInButton()
    let settingsButton = KCFloatingActionButton()
    
    let defaults = UserDefaults.standard
    var wrongPasswordCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        facebookLogin.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        layoutView()
        backgroundImage.addTapToDismissKeyboard()
        beginConnectionTest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton()
        beginConnectionTest()
    }
}

//MARK: UITextFieldDelegate
extension LoginVC {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginWithFirebase()
        }
        
        return true
    }
}

//MARK: Google Sign-in
extension LoginVC {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
            showAlert(.googleSignIn)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        login(withCredential: credential)
    }
}

//MARK: Facebook Login
extension LoginVC {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let _ = error {
            showAlert(.facebookError)
            return
        } else {
            if FBSDKAccessToken.current() != nil && FBSDKAccessToken.current().tokenString != nil {
                if let token = FBSDKAccessToken.current().tokenString {
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: token)
                    login(withCredential: credential)
                }
            } else {
                showAlert(.facebookError)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch {
            showAlert(.firebaseLogout)
        }
    }
}

//---------------
// MARK: - Layout
//---------------
extension LoginVC {
    func layoutView() {
        layoutBackgroundImage()
        layoutLogo()
        layoutUserForm()
        layoutSocialMediaLoginButtons()
        layoutMenuButton()
    }
    
    func layoutBackgroundImage() {
        backgroundImage.image = #imageLiteral(resourceName: "tutorialBG")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.alpha = 0.5
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImage)
        
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func layoutLogo() {
        logoStack.alignment = .fill
        logoStack.axis = .horizontal
        logoStack.distribution = .fillProportionally
        logoStack.spacing = 10
        logoStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mysticView = UIImageView()
        mysticView.image = #imageLiteral(resourceName: "mystic")
        mysticView.contentMode = .scaleAspectFit
        mysticView.translatesAutoresizingMaskIntoConstraints = false
        
        let companionView = UIImageView()
        companionView.image = #imageLiteral(resourceName: "companion")
        companionView.contentMode = .scaleAspectFit
        companionView.translatesAutoresizingMaskIntoConstraints = false
        
        logoStack.addArrangedSubview(mysticView)
        logoStack.addArrangedSubview(companionView)
        
        view.addSubview(logoStack)
        
        logoStack.topAnchor.constraint(equalTo: view.topAnchor, constant: topLayoutConstant).isActive = true
        logoStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        logoStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        logoStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func layoutUserForm() {
        usernameField.delegate = self
        usernameField.backgroundColor = theme.color1
        usernameField.foregroundColor = theme.color
        usernameField.font = UIFont(name: fontFamily, size: 15)
        usernameField.placeholder = "username"
        usernameField.autocapitalizationType = .none
        usernameField.clipsToBounds = true
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        
        emailField.delegate = self
        emailField.backgroundColor = theme.color1
        emailField.foregroundColor = theme.color
        emailField.font = UIFont(name: fontFamily, size: 15)
        emailField.placeholder = "email address"
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.clipsToBounds = true
        emailField.translatesAutoresizingMaskIntoConstraints = false
        
        passwordField.delegate = self
        passwordField.backgroundColor = theme.color1
        passwordField.foregroundColor = theme.color
        passwordField.font = UIFont(name: fontFamily, size: 15)
        passwordField.placeholder = "password"
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        passwordField.clipsToBounds = true
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        
        usernameField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        usernameField.topAnchor.constraint(equalTo: logoStack.bottomAnchor, constant: 10).isActive = true
        usernameField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        usernameField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        emailField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        emailField.topAnchor.constraint(equalTo: usernameField.bottomAnchor).isActive = true
        emailField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        emailField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        passwordField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor).isActive = true
        passwordField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        passwordField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    }
    
    func layoutSocialMediaLoginButtons() {
        facebookLogin.readPermissions = ["public_profile", "email"]
        facebookLogin.translatesAutoresizingMaskIntoConstraints = false
        
        googleLogin.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(facebookLogin)
        view.addSubview(googleLogin)
        
        facebookLogin.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10).isActive = true
        facebookLogin.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        facebookLogin.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        googleLogin.topAnchor.constraint(equalTo: facebookLogin.bottomAnchor, constant: 10).isActive = true
        googleLogin.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        googleLogin.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        googleLogin.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    func layoutMenuButton() {
        settingsButton.setMenuButtonColor()
        settingsButton.setPaddingY(viewHasAds: false)
        settingsButton.items = []
        
        let cancel = KCFloatingActionButtonItem()
        cancel.setButtonOfType(.cancel)
        cancel.handler = { item in
            self.dismiss(animated: true, completion: nil)
        }
        
        let register = KCFloatingActionButtonItem()
        register.setButtonOfType(.registerLogin)
        register.handler = { item in
            self.loginWithFirebase()
        }
        
        settingsButton.addItem(item: cancel)
        settingsButton.addItem(item: register)
        
        view.addSubview(settingsButton)
    }
}

//-----------------
// MARK: - Firebase
//-----------------
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
                    self.defaults.set(username, forKey: "username")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    guard let errorCode = FIRAuthErrorCode(rawValue: error!._code) else { return }
                    switch errorCode {
                    case .errorCodeEmailAlreadyInUse: self.showAlert(.emailAlreadyInUse)
                    case .errorCodeWrongPassword:
                        self.wrongPasswordCount += 1
                        if self.wrongPasswordCount >= 3 {
                            GameHandler.instance.userEmail = email
                            self.showAlert(.resetPassword)
                        } else {
                            self.showAlert(.wrongPassword)
                        }
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
                                FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: nil)
                                self.defaults.set(username, forKey: "username")
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
                case .errorCodeEmailAlreadyInUse: self.showAlert(.emailAlreadyInUse)
                default: self.showAlert(.firebaseError)
                }
                return
            }
            
            guard let user = user else { return }
            let userData: Dictionary<String,Any> = ["provider" : credential.provider,
                                                    "username" : user.displayName as Any,
                                                    "mostManaGainedInOneTurn" : 0,
                                                    "mostVPGainedInOneTurn" : 0,
                                                    "gamesPlayed" : 0,
                                                    "gamesWon" : 0,
                                                    "gamesLost" : 0,
                                                    "mostVPGainedInOneGame" : 0]
            GameHandler.instance.createFirebaseDBUser(uid: user.uid, userData: userData)
            self.defaults.set(user.displayName, forKey: "username")
            self.dismiss(animated: true, completion: nil)
        })
    }
}
