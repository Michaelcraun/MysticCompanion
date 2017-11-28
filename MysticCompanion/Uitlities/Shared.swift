//
//  Shared.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation

class Shared {
    class var instance: Shared {
        struct Singleton {
            static let instance = Shared()
        }
        return Singleton.instance
    }
    
    var PREMIUM_PURCHASED = false
}
