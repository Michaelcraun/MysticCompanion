//
//  KCFloatingActionButtonExtension.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/11/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import KCFloatingActionButton

extension KCFloatingActionButton {
    func setPaddingY() {
        var yPadding: CGFloat {
            switch PREMIUM_PURCHASED {
            case true:
                switch UIDevice.current.modelName {
                case "iPhoneX": return 50
                default: return 20
                }
            case false: return 70
            }
        }
        self.paddingY = yPadding
    }
    
    func setMenuButtonColor() {
        self.buttonColor = theme.color4
    }
}

extension KCFloatingActionButtonItem {
    enum ButtonType {
        case cancel
        case changeTheme
        case contactSupport
        case customVP
        case done
        case drabGray
        case endGame
        case endTurn
        case joinGame
        case logout
        case pastelBlue
        case pastelGreen
        case pastelPurple
        case pastelYellow
        case purchase
        case quitGame
        case registerLogin
        case restore
        case settings
        case standardVP
        case startGame
        
        var title: String {
            switch self {
            case .cancel: return "Cancel"
            case .changeTheme: return "Change Theme"
            case .contactSupport: return "Contact Support"
            case .customVP: return "Custom"
            case .done: return "Done"
            case .drabGray: return "Drab Gray"
            case .endGame: return "End Game"
            case .endTurn: return "End Turn"
            case .joinGame: return "Join Game"
            case .logout: return "Logout"
            case .pastelBlue: return "Pastel Blue"
            case .pastelGreen: return "Pastel Green"
            case .pastelPurple: return "Pastel Purple"
            case .pastelYellow: return "Pastel Yellow"
            case .purchase: return "Purchase Premium"
            case .quitGame: return "Quit Game"
            case .registerLogin: return "Register / Login"
            case .restore: return "Restore Purchases"
            case .settings: return "Settings"
            case .standardVP: return "Standard"
            case .startGame: return "Start Game"
            }
        }
        
        var color: UIColor {
            switch self {
            case .cancel: return UIColor(red: 255 / 255, green: 81 / 255, blue: 72 / 255, alpha: 1)
            case .settings: return UIColor(red: 255 / 255, green: 81 / 255, blue: 72 / 255, alpha: 1)
            //MARK: Theme selection buttons
            case .drabGray: return SystemColor.drabGray.color
            case .pastelBlue: return SystemColor.pastelBlue.color
            case .pastelGreen: return SystemColor.pastelGreen.color
            case .pastelPurple: return SystemColor.pastelPurple.color
            case .pastelYellow: return SystemColor.pastelYellow.color
            //MARK: VP goal selection buttons
            case .customVP: return UIColor(red: 116/255, green: 189/255, blue: 187/255, alpha: 1)
            case .standardVP: return UIColor(red: 116/255, green: 189/255, blue: 187/255, alpha: 1)
            case .done: return theme.color
            //MARK: HomeVC
            case .startGame: return theme.color
            case .joinGame: return theme.color1
            //MARK: SettingsVC
            case .logout: return theme.color
            case .contactSupport: return theme.color1
            case .changeTheme: return theme.color2
            case .purchase: return theme.color3
            case .restore: return theme.color4
            //MARK: GameVC
            case .endTurn: return theme.color
            case .endGame: return theme.color1
            case .quitGame: return theme.color1
            default: return .white
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .cancel: return #imageLiteral(resourceName: "cancelIcon")
            case .contactSupport: return #imageLiteral(resourceName: "emailIcon")
            case .customVP: return #imageLiteral(resourceName: "victory")
            case .done: return #imageLiteral(resourceName: "doneIcon")
            case .endGame: return #imageLiteral(resourceName: "cancelIcon")
            case .endTurn: return #imageLiteral(resourceName: "doneIcon")
            case .joinGame: return #imageLiteral(resourceName: "joinGameIcon")
            case .logout: return #imageLiteral(resourceName: "cancelIcon")
            case .purchase: return #imageLiteral(resourceName: "purchaseIcon")
            case .quitGame: return #imageLiteral(resourceName: "cancelIcon")
            case .restore: return #imageLiteral(resourceName: "restorePurchasesIcon")
            case .settings: return #imageLiteral(resourceName: "settingsIcon")
            case .standardVP: return #imageLiteral(resourceName: "victory")
            case .startGame: return #imageLiteral(resourceName: "startGameIcon")
            default: return nil
            }
        }
    }
    
    func setButtonOfType(_ type: ButtonType) {
        self.title = type.title
        self.buttonColor = type.color
        self.icon = type.icon
    }
}
