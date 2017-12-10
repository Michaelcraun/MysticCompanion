//
//  FirebaseLoginLayout.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import KCFloatingActionButton

extension LoginVC {
    func layoutView() {
        layoutBackgroundImage()
        layoutUserForm()
        layoutSettingsButton()
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
    
    func layoutUserForm() {
        usernameField.backgroundColor = secondaryColor
        usernameField.foregroundColor = primaryColor
        usernameField.font = UIFont(name: fontFamily, size: 15)
        usernameField.placeholder = "username"
        usernameField.autocapitalizationType = .none
        usernameField.clipsToBounds = true
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        
        emailField.backgroundColor = secondaryColor
        emailField.foregroundColor = primaryColor
        emailField.font = UIFont(name: fontFamily, size: 15)
        emailField.placeholder = "email address"
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.clipsToBounds = true
        emailField.translatesAutoresizingMaskIntoConstraints = false
        
        passwordField.backgroundColor = secondaryColor
        passwordField.foregroundColor = primaryColor
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
        usernameField.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
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
    
    func layoutSettingsButton() {
        settingsButton.buttonColor = .black
        settingsButton.paddingX = view.frame.width / 2 - settingsButton.frame.width / 2
        settingsButton.paddingY = 20
        
        let settings = KCFloatingActionButtonItem()
        settings.title = "Settings"
        settings.buttonColor = .red
        settings.handler = { item in
            self.performSegue(withIdentifier: "showSettings", sender: nil)
        }
        
        let cancel = KCFloatingActionButtonItem()
        cancel.title = "Cancel"
        cancel.buttonColor = .white
        cancel.handler = { item in
            self.dismiss(animated: true, completion: nil)
        }
        
        let register = KCFloatingActionButtonItem()
        register.title = "Register / Login"
        register.buttonColor = .white
        register.handler = { item in
            self.loginWithFirebase()
        }
        
        settingsButton.addItem(item: settings)
        settingsButton.addItem(item: cancel)
        settingsButton.addItem(item: register)
        
        view.addSubview(settingsButton)
    }
}
