//
//  Products.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/12/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation

enum Products {
    case premiumUpgrade
    
    var productIdentifier: String {
        switch self {
        case .premiumUpgrade: return "com.CraunicProductions.MysticCompanion.premiumUpgrade"
        }
    }
}
