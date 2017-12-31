//
//  GameHandler.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Firebase
import MapKit

let DB_BASE = FIRDatabase.database().reference()

class GameHandler {
    static let instance = GameHandler()
    var game = [String : AnyObject]()
    
    //MARK: Firebase Variables
    private var _REF_BASE = DB_BASE
    private var _REF_USER = DB_BASE.child("user")
    private var _REF_GAME = DB_BASE.child("game")
    private var _REF_DATA = DB_BASE.child("data")
    
    var REF_BASE: FIRDatabaseReference { return _REF_BASE }
    var REF_USER: FIRDatabaseReference { return _REF_USER }
    var REF_GAME: FIRDatabaseReference { return _REF_GAME }
    var REF_DATA: FIRDatabaseReference { return _REF_DATA }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String,Any>) {
        REF_USER.child(uid).updateChildValues(userData)
    }
    
    func updateFirebaseDBGame(key: String, gameData: Dictionary<String,Any>) {
        REF_GAME.child(key).updateChildValues(gameData)
    }
    
    func createFirebaseDBData() {
        guard let gameKey = game["game"] as? String else { return }
        guard let playersArray = game["players"] as? [Dictionary<String,AnyObject>] else { return }
        var newPlayersArray = [Dictionary<String,AnyObject>]()
        var highestVictory = 0
        var winningPlayer = ""
        
        for player in playersArray {
            guard let username = player["username"] as? String else { return }
            guard let deck = player["deck"] as? String else { return }
            guard let victoryPoints = player["victoryPoints"] as? Int else { return }
            guard let boxVictory = player["boxVictory"] as? Int else { return }
            let totalVictory = victoryPoints + boxVictory
            
            if totalVictory > highestVictory {
                winningPlayer = username
                highestVictory = totalVictory
            }
            
            let newPlayer: Dictionary<String,AnyObject> = ["username" : username as AnyObject,
                                                           "deck" : deck as AnyObject,
                                                           "victoryPoints" : totalVictory as AnyObject]
            
            newPlayersArray.append(newPlayer)
        }
        
        let gameInfo: Dictionary<String,AnyObject> = ["players" : newPlayersArray as AnyObject,
                                                      "winner" : winningPlayer as AnyObject]
        
        REF_DATA.child(gameKey).updateChildValues(gameInfo)
    }
    
    func clearCurrentGamesFromFirebaseDB(forKey key: String) {
        REF_GAME.child(key).removeValue()
    }
}
