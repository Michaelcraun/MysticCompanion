//
//  Constants.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/27/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

/// The font used throughout the application
let fontFamily = "Georgia"

/// The user's currently selected theme
var theme: SystemColor = .pastelGreen
/// An enumeration of colors that make up the user's selected theme
enum SystemColor: String {
    case drabGray =     "Drab Gray"
    case pastelBlue =   "Pastel Blue"
    case pastelGreen =  "Pastel Green"
    case pastelPurple = "Pastel Purple"
    case pastelYellow = "Pastel Yellow"
    static let allThemes: [SystemColor] = [.drabGray, .pastelBlue, .pastelGreen, .pastelPurple, .pastelYellow]
    
    var color: UIColor {
        switch self {
        case .drabGray: return UIColor(red: 131 / 255, green: 131 / 255, blue: 131 / 255, alpha: 1)
        case .pastelBlue: return UIColor(red: 158 / 255, green: 187 / 255, blue: 198 / 255, alpha: 1)
        case .pastelGreen: return UIColor(red: 99 / 255, green: 216 / 255, blue: 99 / 255, alpha: 1)
        case .pastelPurple: return UIColor(red: 168 / 255, green: 144 / 255, blue: 170 / 255, alpha: 1)
        case .pastelYellow: return UIColor(red: 252 / 255, green: 252 / 255, blue: 100 / 255, alpha: 1)
        }
    }
    
    var color1: UIColor {
        switch self {
        case .drabGray: return UIColor(red: 144 / 255, green: 144 / 255, blue: 144 / 255, alpha: 1)
        case .pastelBlue: return UIColor(red: 174 / 255, green: 198 / 255, blue: 207 / 255, alpha: 1)
        case .pastelGreen: return UIColor(red: 119 / 255, green: 221 / 255, blue: 119 / 255, alpha: 1)
        case .pastelPurple: return UIColor(red: 179 / 255, green: 158 / 255, blue: 181 / 255, alpha: 1)
        case .pastelYellow: return UIColor(red: 252 / 255, green: 252 / 255, blue: 100 / 255, alpha: 1)
        }
    }
    
    var color2: UIColor {
        switch self {
        case .drabGray: return UIColor(red: 156 / 255, green: 156 / 255, blue: 156 / 255, alpha: 1)
        case .pastelBlue: return UIColor(red: 190 / 255, green: 209 / 255, blue: 216 / 255, alpha: 1)
        case .pastelGreen: return UIColor(red: 139 / 255, green: 226 / 255, blue: 139 / 255, alpha: 1)
        case .pastelPurple: return UIColor(red: 190 / 255, green: 172 / 255, blue: 192 / 255, alpha: 1)
        case .pastelYellow: return UIColor(red: 253 / 255, green: 253 / 255, blue: 150 / 255, alpha: 1)
        }
    }
    
    var color3: UIColor {
        switch self {
        case .drabGray: return UIColor(red: 169 / 255, green: 169 / 255, blue: 169 / 255, alpha: 1)
        case .pastelBlue: return UIColor(red: 206 / 255, green: 221 / 255, blue: 226 / 255, alpha: 1)
        case .pastelGreen: return UIColor(red: 160 / 255, green: 231 / 255, blue: 160 / 255, alpha: 1)
        case .pastelPurple: return UIColor(red: 202 / 255, green: 187 / 255, blue: 203 / 255, alpha: 1)
        case .pastelYellow: return UIColor(red: 253 / 255, green: 253 / 255, blue: 175 / 255, alpha: 1)
        }
    }
    
    var color4: UIColor {
        switch self {
        case .drabGray: return UIColor(red: 182 / 255, green: 182 / 255, blue: 182 / 255, alpha: 1)
        case .pastelBlue: return UIColor(red: 222 / 255, green: 232 / 255, blue: 235 / 255, alpha: 1)
        case .pastelGreen: return UIColor(red: 180 / 255, green: 236 / 255, blue: 180 / 255, alpha: 1)
        case .pastelPurple: return UIColor(red: 213 / 255, green: 201 / 255, blue: 214 / 255, alpha: 1)
        case .pastelYellow: return UIColor(red: 254 / 255, green: 254 / 255, blue: 200 / 255, alpha: 1)
        }
    }
}

/// An enumeration of deck types
enum DeckType: String {
    case beastbrothers
    case dawnseekers
    case lifewardens
    case waveguards
    
    /// The primary color associated with the DeckType
    var color: UIColor {
        switch self {
        case .beastbrothers: return UIColor(red: 190 / 255, green: 50 / 255, blue: 44 / 255, alpha: 1)
        case .dawnseekers: return UIColor(red: 246 / 255, green: 207 / 255, blue: 83 / 255, alpha: 1)
        case .lifewardens: return UIColor(red: 128 / 255, green: 181 / 255, blue: 67 / 255, alpha: 1)
        case .waveguards: return UIColor(red: 33 / 255, green: 94 / 255, blue: 135 / 255, alpha: 1)
        }
    }
    
    /// The secondary color associated with the DeckType
    var secondaryColor: UIColor {
        switch self {
        case .beastbrothers: return UIColor(red: 190 / 255, green: 50 / 255, blue: 44 / 255, alpha: 0.5)
        case .dawnseekers: return UIColor(red: 246 / 255, green: 207 / 255, blue: 83 / 255, alpha: 0.5)
        case .lifewardens: return UIColor(red: 128 / 255, green: 181 / 255, blue: 67 / 255, alpha: 0.5)
        case .waveguards: return UIColor(red: 33 / 255, green: 94 / 255, blue: 135 / 255, alpha: 0.5)
        }
    }
    
    /// The image associated with the DeckType
    var image: UIImage {
        switch self {
        case .beastbrothers: return #imageLiteral(resourceName: "beastbrothers")
        case .dawnseekers: return #imageLiteral(resourceName: "dawnseekers")
        case .lifewardens: return #imageLiteral(resourceName: "lifewardens")
        case .waveguards: return #imageLiteral(resourceName: "waveguards")
        }
    }
}

/// Access point for the AppDelegate
let ad = UIApplication.shared.delegate as! AppDelegate
/// Access point for the CoreData context
let context = ad.persistentContainer.viewContext

/// A Boolean value determining if the user has purchased premium
var PREMIUM_PURCHASED = false

/// A CGFloat value representing the y value of the top safe edge of the screen
var topLayoutConstant: CGFloat {
    switch UIDevice.current.modelName {
    case "iPhone X" : return 44
    default: return 20
    }
}

/// A CGFloat value representing the y value of the bottom safe edge of the screen
var bottomLayoutConstant: CGFloat {
    switch UIDevice.current.modelName {
    case "iPhone X": return 34
    default: return 0
    }
}

/// A CGFloat value representing the height of ads
var adBuffer: CGFloat {
    switch PREMIUM_PURCHASED {
    case true: return 0
    case false: return 50
    }
}

/// A CGFloat value representing the height of any banners displayed at the top of the screen
var topBannerHeight: CGFloat {
    switch UIDevice.current.modelName {
    case "iPhone X": return 88
    default: return 64
    }
}
