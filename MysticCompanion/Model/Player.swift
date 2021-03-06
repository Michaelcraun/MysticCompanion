//
//  Player.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation

protocol PlayerProtocol {
    var username:       String { get set }
    var deck: 	        DeckType { get set }
    var manaConstant:   Int { get set }
    var decayConstant:  Int { get set }
    var growthConstant: Int { get set }
    var animalConstant: Int { get set }
    var forestConstant: Int { get set }
    var skyConstant:    Int { get set }
    var wildConstant:   Int { get set }
    var currentVP:      Int { get set }
    var boxVP:          Int { get set }
}

/// A Singleton that holds all of the current user's information
class Player: PlayerProtocol {
    static let instance = Player()
    
    var username:       String = ""
    var deck:           DeckType = .beastbrothers
    var manaConstant:   Int = 0
    var decayConstant:  Int = 0
    var growthConstant: Int = 0
    var animalConstant: Int = 0
    var forestConstant: Int = 0
    var skyConstant:    Int = 0
    var wildConstant:   Int = 0
    var currentVP:      Int = 0
    var boxVP:          Int = 0
    
    /// Resets the Player Singleton (should be called when the user quits the game)
    func reinitialize() {
        manaConstant =      0
        decayConstant =     0
        growthConstant =    0
        animalConstant =    0
        forestConstant =    0
        skyConstant =       0
        wildConstant =      0
        currentVP =         0
        boxVP =             0
    }
}
