//
//  SettingsFirebase.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/29/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

extension SettingsVC {
    func observeDataForGamesPlayed() {
        var gamesPlayed = [Dictionary<String,AnyObject>]()
        GameHandler.instance.REF_DATA.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dataSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            for data in dataSnapshot {
                guard let dataPlayersArray = data.childSnapshot(forPath: "players").value as? [Dictionary<String,AnyObject>] else { return }
                for player in dataPlayersArray {
                    guard let playerUsername = player["username"] as? String else { return }
                    if playerUsername == Player.instance.username {
                        guard let previousGame = data.value as? Dictionary<String,AnyObject> else { return }
                        gamesPlayed.append(previousGame)
                    }
                }
            }
            self.previousGames = gamesPlayed
        })
    }
    
    func logout() {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            dismiss(animated: true, completion: nil)
        } catch {
            showAlert(.firebaseLogout)
        }
    }
}
