//
//  FirebaseLoginLayout.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import KCFloatingActionButton
import Firebase

import TwitterKit
import GoogleSignIn

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
        
        logoStack.topAnchor.constraint(equalTo: view.topAnchor, constant: UIDevice.current.topLayoutBuffer).isActive = true
        logoStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        logoStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        logoStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func layoutUserForm() {
        usernameField.backgroundColor = theme.color1
        usernameField.foregroundColor = theme.color
        usernameField.font = UIFont(name: fontFamily, size: 15)
        usernameField.placeholder = "username"
        usernameField.autocapitalizationType = .none
        usernameField.clipsToBounds = true
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        
        emailField.backgroundColor = theme.color1
        emailField.foregroundColor = theme.color
        emailField.font = UIFont(name: fontFamily, size: 15)
        emailField.placeholder = "email address"
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.clipsToBounds = true
        emailField.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        twitterLogin = TWTRLogInButton(logInCompletion: { (session, error) in
            self.twitterLoginCompletion(session: session, error: error)
        })
        twitterLogin.translatesAutoresizingMaskIntoConstraints = false
        
        googleLogin.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(facebookLogin)
        view.addSubview(twitterLogin)
        view.addSubview(googleLogin)
        
        facebookLogin.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10).isActive = true
        facebookLogin.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        facebookLogin.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        twitterLogin.topAnchor.constraint(equalTo: facebookLogin.bottomAnchor, constant: 10).isActive = true
        twitterLogin.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        twitterLogin.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        twitterLogin.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        googleLogin.topAnchor.constraint(equalTo: twitterLogin.bottomAnchor, constant: 10).isActive = true
        googleLogin.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        googleLogin.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        googleLogin.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    func layoutMenuButton() {
        settingsButton.setMenuButtonColor()
        settingsButton.setPaddingY()
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
