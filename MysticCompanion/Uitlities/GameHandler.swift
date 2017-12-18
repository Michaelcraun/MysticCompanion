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
    
    //MARK: Firebase Variables
    private var _REF_BASE = DB_BASE
    private var _REF_USER = DB_BASE.child("user")
    private var _REF_GAME = DB_BASE.child("game")
    
    var REF_BASE: FIRDatabaseReference { return _REF_BASE }
    var REF_USER: FIRDatabaseReference { return _REF_USER }
    var REF_GAME: FIRDatabaseReference { return _REF_GAME }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String,Any>) {
        REF_USER.child(uid).updateChildValues(userData)
    }
    
    func updateFirebaseDBGame(key: String, gameData: Dictionary<String,Any>) {
        REF_GAME.child(key).updateChildValues(gameData)
    }
    
    func clearCurrentGamesFromFirebaseDB(forKey key: String) {
        REF_GAME.child(key).removeValue()
    }
    
    func quitGameForUser(_ username: String) {
        guard let game = game["game"] as? String else { return }
        removeFromGame(game, withUser: username)
        Player.instance.reinitialize()
    }
    
    func removeFromGame(_ key: String, withUser username: String) {
        var newPlayersArray = [Dictionary<String,AnyObject>]()
        GameHandler.instance.REF_GAME.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let gameSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for game in gameSnapshot {
                if game.key == key {
                    guard let playersArray = game.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                    for player in playersArray {
                        guard let fbPlayerUsername = player["username"] as? String else { return }
                        if fbPlayerUsername != username {
                            newPlayersArray.append(player)
                        }
                    }
                    self.updateFirebaseDBGame(key: game.key, gameData: ["players" : newPlayersArray])
                }
            }
        })
    }
    
    var game = [String : AnyObject]() {
        willSet (newGame) {
            
        }
    }
}
