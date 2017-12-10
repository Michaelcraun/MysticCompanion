//
//  Player.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation

class Player {
    var username: String
    var deck: DeckType
    
    init(username: String, deck: DeckType) {
        self.username = username
        self.deck = deck
    }
}
