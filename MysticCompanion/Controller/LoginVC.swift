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

class LoginVC: UIViewController, UITextFieldDelegate, GIDSignInDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    let backgroundImage = UIImageView()
    let logoStack = UIStackView()
    let usernameField = KaedeTextField()
    let emailField = KaedeTextField()
    let passwordField = KaedeTextField()
    var facebookLogin = FBSDKLoginButton()
    var googleLogin = GIDSignInButton()
    let settingsButton = KCFloatingActionButton()
    
    let firManager = FirebaseManager()
    
    let defaults = UserDefaults.standard

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
        firManager.delegate = self
        
        checkTheme()
        layoutMenuButton()
        beginConnectionTest()
    }
}

//----------------------------
// MARK: - UITextFieldDelegate
//----------------------------
extension LoginVC {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            verifyCredentials()
        }
        
        return true
    }
}

//-----------------------
// MARK: - Google Sign-in
//-----------------------
extension LoginVC {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
            showAlert(.googleSignIn)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        firManager.login(withCredential: credential)
    }
}

//-----------------------
// MARK: - Facebook Login
//-----------------------
extension LoginVC {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let _ = error {
            showAlert(.facebookError)
            return
        } else {
            if FBSDKAccessToken.current() != nil && FBSDKAccessToken.current().tokenString != nil {
                if let token = FBSDKAccessToken.current().tokenString {
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: token)
                    firManager.login(withCredential: credential)
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
    /// The central point for layout of LoginVC
    func layoutView() {
        setBackgroundImage(#imageLiteral(resourceName: "loginBG"))
        layoutLogo()
        layoutUserForm()
        layoutSocialMediaLoginButtons()
        layoutMenuButton()
    }
    
    /// Configures stack view containing logo
    func layoutLogo() {
        
        let mysticView = UIImageView()
        mysticView.image = #imageLiteral(resourceName: "mystic")
        mysticView.contentMode = .scaleAspectFit
        mysticView.anchorTo()
        
        let companionView = UIImageView()
        companionView.image = #imageLiteral(resourceName: "companion")
        companionView.contentMode = .scaleAspectFit
        mysticView.anchorTo()
        
        logoStack.addArrangedSubview(mysticView)
        logoStack.addArrangedSubview(companionView)
        logoStack.alignment = .fill
        logoStack.axis = .horizontal
        logoStack.distribution = .fillProportionally
        logoStack.spacing = 10
        
        logoStack.anchorTo(view,
                           top: view.topAnchor,
                           leading: view.leadingAnchor,
                           trailing: view.trailingAnchor,
                           padding: .init(top: topLayoutConstant, left: 10, bottom: 0, right: 10),
                           size: .init(width: 0, height: 50))
    }
    
    /// Configures the login form
    func layoutUserForm() {
        usernameField.delegate = self
        usernameField.backgroundColor = theme.color1
        usernameField.foregroundColor = theme.color
        usernameField.font = UIFont(name: fontFamily, size: 15)
        usernameField.placeholder = "username"
        usernameField.autocapitalizationType = .none
        usernameField.clipsToBounds = true
        
        emailField.delegate = self
        emailField.backgroundColor = theme.color1
        emailField.foregroundColor = theme.color
        emailField.font = UIFont(name: fontFamily, size: 15)
        emailField.placeholder = "email address"
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.clipsToBounds = true
        
        passwordField.delegate = self
        passwordField.backgroundColor = theme.color1
        passwordField.foregroundColor = theme.color
        passwordField.font = UIFont(name: fontFamily, size: 15)
        passwordField.placeholder = "password"
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        passwordField.clipsToBounds = true
        
        usernameField.anchorTo(view,
                               top: logoStack.bottomAnchor,
                               leading: view.leadingAnchor,
                               trailing: view.trailingAnchor,
                               padding: .init(top: 30, left: 20, bottom: 0, right: 20),
                               size: .init(width: 0, height: 30))
        
        emailField.anchorTo(view,
                            top: usernameField.bottomAnchor,
                            leading: view.leadingAnchor,
                            trailing: view.trailingAnchor,
                            padding: .init(top: 30, left: 20, bottom: 0, right: 20),
                            size: .init(width: 0, height: 30))
        
        passwordField.anchorTo(view,
                               top: emailField.bottomAnchor,
                               leading: view.leadingAnchor,
                               trailing: view.trailingAnchor,
                               padding: .init(top: 30, left: 20, bottom: 0, right: 20),
                               size: .init(width: 0, height: 30))
    }
    
    /// Configures the social media buttons
    func layoutSocialMediaLoginButtons() {
        facebookLogin.readPermissions = ["public_profile", "email"]
        
        facebookLogin.anchorTo(view,
                               top: passwordField.bottomAnchor,
                               leading: view.leadingAnchor,
                               trailing: view.trailingAnchor,
                               padding: .init(top: 10, left: 20, bottom: 0, right: 20))
        
        googleLogin.anchorTo(view,
                             top: facebookLogin.bottomAnchor,
                             leading: view.leadingAnchor,
                             trailing: view.trailingAnchor,
                             padding: .init(top: 10, left: 20, bottom: 0, right: 20),
                             size: .init(width: 0, height: 28))
    }
    
    /// Configures the menu button for HomeVC
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
            self.verifyCredentials()
        }
        
        settingsButton.addItem(item: cancel)
        settingsButton.addItem(item: register)
        settingsButton.anchorTo(view)
    }
    
    private func verifyCredentials() {
        self.view.endEditing(true)
        guard let username = self.usernameField.text, username != "",
            let email = self.emailField.text, email != "",
            let password = self.passwordField.text, password != "" else {
                self.showAlert(.invalidLogin)
                return
        }
        
        firManager.loginWithFirebase(username: username, email: email, password: password)
    }
}
