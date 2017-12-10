//
//  SettingsCoreData.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import CoreData

extension SettingsVC: NSFetchedResultsControllerDelegate {
    func attemptGameFetch() {
        
        let dateSort = NSSortDescriptor(key: "datePlayed", ascending: true)
        fetchRequest.sortDescriptors = [dateSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        self.controller = controller
        
        do {
            try controller.performFetch()
        } catch {
            let error = error as NSError
            print("Error: \(error)")
        }
    }
}
