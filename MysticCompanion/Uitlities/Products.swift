//
//  Products.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/12/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation

/// An enumeration of products available in the app
enum Products {
    case premiumUpgrade
    
    /// The identifier of the product
    var productIdentifier: String {
        switch self {
        case .premiumUpgrade: return "com.CraunicProductions.MysticCompanion.PremiumUpgrade"
        }
    }
}
