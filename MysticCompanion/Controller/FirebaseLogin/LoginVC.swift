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

import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import GoogleSignIn

class LoginVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    let backgroundImage = UIImageView()
    let logoStack = UIStackView()
    let usernameField = KaedeTextField()
    let emailField = KaedeTextField()
    let passwordField = KaedeTextField()
    
    var facebookLogin = FBSDKLoginButton()
    var twitterLogin = TWTRLogInButton()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton()
    }
}

//MARK: Google Sign-in
extension LoginVC {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //TODO: Get GoogleSignIn talking to Firebase
        if let _ = error {
            showAlert(withTitle: "Google Sign-In Error:", andMessage: "There was an unexpected error when attempting to sign in with Google. Please try again.", andNotificationType: .error)
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
            showAlert(withTitle: "Facebook Error:", andMessage: "There was an unexpected error whtn attempting to sign in with Facebook. Please try again.", andNotificationType: .error)
            return
        }
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        login(withCredential: credential)
        print("Successfully logged in user with Facebook.")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
}

//MARK: Twitter Login
extension LoginVC {
    func twitterLoginCompletion(session: TWTRSession?, error: Error!) {
        if let _ = error {
            showAlert(withTitle: "Twitter Error:", andMessage: "There was an unexpected error when attempting to sign in with Twitter. Please try again.", andNotificationType: .error)
            //Returning "Request failed: unauthorized (401) error
            //Usually means missing Consumer Secret or Consumer Secret, but these are correct...
            return
        }
        
        guard let authToken = session?.authToken else { return }
        guard let authTokenSecret = session?.authTokenSecret else { return }
        let credential = FIRTwitterAuthProvider.credential(withToken: authToken, secret: authTokenSecret)
        login(withCredential: credential)
        print("successfully logged in under twitter")
    }
}
