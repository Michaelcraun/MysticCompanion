//
//  Constants.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/27/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

//MARK: Font Variables
let fontFamily = "Georgia"

//MARK: Colors
let blue = UIColor(red: 33 / 255, green: 94 / 255, blue: 135 / 255, alpha: 1)
let green = UIColor(red: 128 / 255, green: 181 / 255, blue: 67 / 255, alpha: 1)
let red = UIColor(red: 190 / 255, green: 50 / 255, blue: 44 / 255, alpha: 1)
let yellow = UIColor(red: 246 / 255, green: 207 / 255, blue: 83 / 255, alpha: 1)

let blueLessAlpha = UIColor(red: 33 / 255, green: 94 / 255, blue: 135 / 255, alpha: 0.5)
let greenLessAlpha = UIColor(red: 128 / 255, green: 181 / 255, blue: 67 / 255, alpha: 0.5)
let redLessAlpha = UIColor(red: 190 / 255, green: 50 / 255, blue: 44 / 255, alpha: 0.5)
let yellowLessAlpha = UIColor(red: 246 / 255, green: 207 / 255, blue: 83 / 255, alpha: 0.5)


enum DeckType {
    case beastbrothers
    case dawnseekers
    case lifewardens
    case waveguards
    
    var color: UIColor {
        switch self {
        case .beastbrothers: return red
        case .dawnseekers: return yellow
        case .lifewardens: return green
        case .waveguards: return blue
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
