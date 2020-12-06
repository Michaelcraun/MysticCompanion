//
//  GameHandler.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import MapKit

import Firebase
import FirebaseAuth
import FirebaseDatabase

let DB_BASE = FIRDatabase.database().reference()

/// The GameHandler Singleton that handles communication between Firebase and the app
class GameHandler {
    static let instance = GameHandler()
    
    //MARK: - Firebase Variables
    private var _REF_BASE = DB_BASE
    private var _REF_USER = DB_BASE.child("user")
    private var _REF_GAME = DB_BASE.child("game")
    private var _REF_DATA = DB_BASE.child("data")
    
    var REF_BASE: FIRDatabaseReference { return _REF_BASE }
    var REF_USER: FIRDatabaseReference { return _REF_USER }
    var REF_GAME: FIRDatabaseReference { return _REF_GAME }
    var REF_DATA: FIRDatabaseReference { return _REF_DATA }
    var game = [String : Any]() {
        didSet {
            print("GAME: currentGame: \(game.debugDescription)")
        }
    }
    var userEmail = ""
    
    //MARK: - Firebase user functions
    /// Creates and/or updates a specific on Firebase
    /// - parameter uid: The unique identifier specific to an individual user
    /// - parameter userData: A Dictionary that contains the data with which to update the specified user
    func createFirebaseDBUser(uid: String, userData: [String : Any]) {
        REF_USER.child(uid).updateChildValues(userData)
    }
    
    /// Sends a request to the user to reset their password
    /// - returns: A Boolean value determining if the request encountered an error or not
    func resetPassword() -> Bool {
        var hasError = false
        FIRAuth.auth()?.sendPasswordReset(withEmail: userEmail, completion: { (error) in
            if let _ = error {
                hasError = true
            }
        })
        return hasError
    }
    
    //MARK: - Firebase game functions
    /// Creates and/or updates a specific game on Firebase
    /// - parameter key: The unique identifier specific to an individual game
    /// - parameter gameData: A Dictionary that contains the data with which to update the specified game
    func updateFirebaseDBGame(key: String, gameData: [String : Any]) {
        REF_GAME.child(key).updateChildValues(gameData)
    }
    
    /// Removes all games with a specific key from Firebase
    /// - parameter key: The unique identifier specific to an individual game
    func clearCurrentGamesFromFirebaseDB(forKey key: String) {
        REF_GAME.child(key).removeValue()
    }
    
    //MARK: - Firebase data functions
    /// Creates a data entry for a specific game to store on Firebase
    /// - parameter key: The unique identifier specific to an individual game
    /// - parameter playersArray: An Array of Dictionary values representing the players in the specified game
    /// - parameter winners: An Array of String values representing the winners in the specified game
    /// - parameter date: The Date value representing the day and time the game was played
    func createFirebaseDBData(forGame key: String, withPlayers playersArray: [[String : AnyObject]], andWinners winners: [String], andDateString date: String?) {
        var gameKeyAddendum: String {
            if date == nil {
                return generateDateAddendum()
            } else {
                return date!
            }
        }
        let gameKey = "\(gameKeyAddendum)-\(key)"
        var newPlayersArray = [[String : AnyObject]]()
        
        for player in playersArray {
            guard let username = player["username"] as? String else { return }
            guard let deck = player["deck"] as? String else { return }
            guard let victoryPoints = player["victoryPoints"] as? Int else { return }
            guard let boxVictory = player["boxVictory"] as? Int else { return }
            let totalVictory = victoryPoints + boxVictory
            
            let newPlayer: [String : AnyObject] = ["username" : username as AnyObject,
                                                   "deck" : deck as AnyObject,
                                                   "victoryPoints" : totalVictory as AnyObject]
            
            newPlayersArray.append(newPlayer)
        }
        
        let gameData: [String : AnyObject] = ["players" : newPlayersArray as AnyObject,
                                              "winners" : winners as AnyObject]
        
        REF_DATA.child(gameKey).updateChildValues(gameData)
    }
    
    /// Allows for differentiating between games played when storing game data on Firebase
    /// - returns: A String representing the date the game was played
    private func generateDateAddendum() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "MMDDYYYY HH:mm"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
}
