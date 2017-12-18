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

class LoginVC: UIViewController {
    let backgroundImage = UIImageView()
    let logoStack = UIStackView()
    let usernameField = KaedeTextField()
    let emailField = KaedeTextField()
    let passwordField = KaedeTextField()
    let facebookLogin = UIButton()
    let settingsButton = KCFloatingActionButton()
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutView()
        //TODO: Test tapToDismissKeyboard
        backgroundImage.addTapToDismissKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkTheme()
        layoutMenuButton()
    }
}
