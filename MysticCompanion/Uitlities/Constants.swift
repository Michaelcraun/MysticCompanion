//
//  Constants.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/27/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

//MARK: UI Variables
let fontFamily = "Georgia"

//MARK: Colors
var theme: SystemColor = .pastelGreen
enum SystemColor: String {
    case drabGray
    case pastelBlue
    case pastelGreen
    case pastelPurple
    case pastelYellow
    
    var color: UIColor {
        switch self {
        case .drabGray: return UIColor(red: 131 / 255, green: 131 / 255, blue: 131 / 255, alpha: 1)         //131, 131, 131
        case .pastelBlue: return UIColor(red: 158 / 255, green: 187 / 255, blue: 198 / 255, alpha: 1)       //158, 187, 198
        case .pastelGreen: return UIColor(red: 99 / 255, green: 216 / 255, blue: 99 / 255, alpha: 1)        //99, 216, 99
        case .pastelPurple: return UIColor(red: 168 / 255, green: 144 / 255, blue: 170 / 255, alpha: 1)     //168, 144, 170
        case .pastelYellow: return UIColor(red: 252 / 255, green: 252 / 255, blue: 100 / 255, alpha: 1)     //252, 252, 100
        }
    }
    
    var color1: UIColor {
        switch self {
        case .drabGray: return UIColor(red: 144 / 255, green: 144 / 255, blue: 144 / 255, alpha: 1)         //144, 144, 144
        case .pastelBlue: return UIColor(red: 174 / 255, green: 198 / 255, blue: 207 / 255, alpha: 1)       //174, 198, 207
        case .pastelGreen: return UIColor(red: 119 / 255, green: 221 / 255, blue: 119 / 255, alpha: 1)      //119, 221, 119
        case .pastelPurple: return UIColor(red: 179 / 255, green: 158 / 255, blue: 181 / 255, alpha: 1)     //179, 158, 181
        case .pastelYellow: return UIColor(red: 252 / 255, green: 252 / 255, blue: 100 / 255, alpha: 1)     //253, 253, 125
        }
    }
    
    var color2: UIColor {
        switch self {
        case .drabGray: return UIColor(red: 156 / 255, green: 156 / 255, blue: 156 / 255, alpha: 1)         //156, 156, 156
        case .pastelBlue: return UIColor(red: 190 / 255, green: 209 / 255, blue: 216 / 255, alpha: 1)       //190, 209, 216
        case .pastelGreen: return UIColor(red: 139 / 255, green: 226 / 255, blue: 139 / 255, alpha: 1)      //139, 226, 139
        case .pastelPurple: return UIColor(red: 190 / 255, green: 172 / 255, blue: 192 / 255, alpha: 1)     //190, 172, 192
        case .pastelYellow: return UIColor(red: 253 / 255, green: 253 / 255, blue: 150 / 255, alpha: 1)     //253, 253, 150
        }
    }
    
    var color3: UIColor {
        switch self {
        case .drabGray: return UIColor(red: 169 / 255, green: 169 / 255, blue: 169 / 255, alpha: 1)         //169, 169, 169
        case .pastelBlue: return UIColor(red: 206 / 255, green: 221 / 255, blue: 226 / 255, alpha: 1)       //206, 221, 226
        case .pastelGreen: return UIColor(red: 160 / 255, green: 231 / 255, blue: 160 / 255, alpha: 1)      //160, 231, 160
        case .pastelPurple: return UIColor(red: 202 / 255, green: 187 / 255, blue: 203 / 255, alpha: 1)     //202, 187, 203
        case .pastelYellow: return UIColor(red: 253 / 255, green: 253 / 255, blue: 175 / 255, alpha: 1)     //253, 253, 175
        }
    }
    
    var color4: UIColor {
        switch self {
        case .drabGray: return UIColor(red: 182 / 255, green: 182 / 255, blue: 182 / 255, alpha: 1)         //182, 182, 182
        case .pastelBlue: return UIColor(red: 222 / 255, green: 232 / 255, blue: 235 / 255, alpha: 1)       //222, 232, 235
        case .pastelGreen: return UIColor(red: 180 / 255, green: 236 / 255, blue: 180 / 255, alpha: 1)      //180, 236, 180
        case .pastelPurple: return UIColor(red: 213 / 255, green: 201 / 255, blue: 214 / 255, alpha: 1)     //213, 201, 214
        case .pastelYellow: return UIColor(red: 254 / 255, green: 254 / 255, blue: 200 / 255, alpha: 1)     //254, 254, 200
        }
    }
}

enum DeckType: String {
    case beastbrothers
    case dawnseekers
    case lifewardens
    case waveguards
    
    var color: UIColor {
        switch self {
        case .beastbrothers: return UIColor(red: 190 / 255, green: 50 / 255, blue: 44 / 255, alpha: 1)
        case .dawnseekers: return UIColor(red: 246 / 255, green: 207 / 255, blue: 83 / 255, alpha: 1)
        case .lifewardens: return UIColor(red: 128 / 255, green: 181 / 255, blue: 67 / 255, alpha: 1)
        case .waveguards: return UIColor(red: 33 / 255, green: 94 / 255, blue: 135 / 255, alpha: 1)
        }
    }
    
    var secondaryColor: UIColor {
        switch self {
        case .beastbrothers: return UIColor(red: 190 / 255, green: 50 / 255, blue: 44 / 255, alpha: 0.5)
        case .dawnseekers: return UIColor(red: 246 / 255, green: 207 / 255, blue: 83 / 255, alpha: 0.5)
        case .lifewardens: return UIColor(red: 128 / 255, green: 181 / 255, blue: 67 / 255, alpha: 0.5)
        case .waveguards: return UIColor(red: 33 / 255, green: 94 / 255, blue: 135 / 255, alpha: 0.5)
        }
    }
    
    var image: UIImage {
        switch self {
        case .beastbrothers: return #imageLiteral(resourceName: "beastbrothers")
        case .dawnseekers: return #imageLiteral(resourceName: "dawnseekers")
        case .lifewardens: return #imageLiteral(resourceName: "lifewardens")
        case .waveguards: return #imageLiteral(resourceName: "waveguards")
        }
    }
}

let ad = UIApplication.shared.delegate as! AppDelegate
let context = ad.persistentContainer.viewContext

//TODO: Set to false before publishing
var PREMIUM_PURCHASED = false

//MARK: Layout Constraint Variables
//TODO: Needs fixed for iPhone X ?
var topLayoutConstant: CGFloat {
    switch UIDevice.current.modelName {
    case "iPhoneX" : return 88
    default: return 20
    }
}

var bottomLayoutConstant: CGFloat {
    switch UIDevice.current.modelName {
    case "iPhoneX": return -34
    default: return 0
    }
}

var adBuffer: CGFloat {
    switch PREMIUM_PURCHASED {
    case true: return 0
    case false: return -50
    }
}

var topBannerHeight: CGFloat {
    switch UIDevice.current.modelName {
    case "iPhone X": return 88
    default: return 64
    }
}
