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

class LoginVC: UIViewController, Connection, GIDSignInDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    let backgroundImage = UIImageView()
    let logoStack = UIStackView()
    let usernameField = KaedeTextField()
    let emailField = KaedeTextField()
    let passwordField = KaedeTextField()
    
    var facebookLogin = FBSDKLoginButton()
    var googleLogin = GIDSignInButton()
    
    let settingsButton = KCFloatingActionButton()
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        facebookLogin.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        layoutView()
        //TODO: Test tapToDismissKeyboard
        backgroundImage.addTapToDismissKeyboard()
        beginConnectionTest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton()
        beginConnectionTest()
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
        }
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        login(withCredential: credential)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
}
