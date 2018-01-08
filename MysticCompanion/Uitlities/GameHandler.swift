//
//  GameHandler.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
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
    
    //MARK: Firebase user functions
    func createFirebaseDBUser(uid: String, userData: Dictionary<String,Any>) {
        REF_USER.child(uid).updateChildValues(userData)
    }
    
    //MARK: Firebase game functions
    func updateFirebaseDBGame(key: String, gameData: Dictionary<String,Any>) {
        REF_GAME.child(key).updateChildValues(gameData)
    }
    
    func clearCurrentGamesFromFirebaseDB(forKey key: String) {
        REF_GAME.child(key).removeValue()
    }
    
    //MARK: Firebase data functions
    func createFirebaseDBData(forGame key: String, withPlayers playersArray: [Dictionary<String,AnyObject>], andWinners winners: [String]) {
        let gameKeyAddendum = generateDateAddendum()
        let gameKey = "\(gameKeyAddendum)-\(key)"
        var newPlayersArray = [Dictionary<String,AnyObject>]()
        
        for player in playersArray {
            guard let username = player["username"] as? String else { return }
            guard let deck = player["deck"] as? String else { return }
            guard let victoryPoints = player["victoryPoints"] as? Int else { return }
            guard let boxVictory = player["boxVictory"] as? Int else { return }
            let totalVictory = victoryPoints + boxVictory
            
            let newPlayer: Dictionary<String,AnyObject> = ["username" : username as AnyObject,
                                                           "deck" : deck as AnyObject,
                                                           "victoryPoints" : totalVictory as AnyObject]
            
            newPlayersArray.append(newPlayer)
        }
        
        let gameData: Dictionary<String,AnyObject> = ["players" : newPlayersArray as AnyObject,
                                                      "winners" : winners as AnyObject]
        
        REF_DATA.child(gameKey).updateChildValues(gameData)
    }
    
    //MARK: Allows for differentiating between games played
    func generateDateAddendum() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "MMDDYYYY HH:mm"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
}
