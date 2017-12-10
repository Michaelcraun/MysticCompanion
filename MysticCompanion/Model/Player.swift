//
//  Player.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation

protocol PlayerProtocol {
    var username: String { get set }
    var deck: DeckType? { get set }
    var manaConstant: Int { get set }
    var decayConstant: Int { get set }
    var growthConstant: Int { get set }
    var animalConstant: Int { get set }
    var forestConstant: Int { get set }
    var skyConstant: Int { get set }
    var wildConstant: Int { get set }
    var currentVP: Int { get set }
    var boxVP: Int { get set }
}

class Player: PlayerProtocol {
    var username: String = ""
    var deck: DeckType? = nil
    var manaConstant: Int = 0
    var decayConstant: Int = 0
    var growthConstant: Int = 0
    var animalConstant: Int = 0
    var forestConstant: Int = 0
    var skyConstant: Int = 0
    var wildConstant: Int = 0
    var currentVP: Int = 0
    var boxVP: Int = 0
}
