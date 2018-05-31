//
//  AppDelegate.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/27/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

import Firebase
import FirebaseAuth
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var shortcutItem: UIApplicationShortcutItem?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var isLaunchedFromQuickAction = false
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            self.shortcutItem = shortcutItem
            isLaunchedFromQuickAction = true
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        FIRApp.configure()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization( options: authOptions, completionHandler: {_, _ in
                
            })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        application.registerForRemoteNotifications()
        
        return isLaunchedFromQuickAction
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let shortcut = shortcutItem else { return }
        let _ = handleQuickAction(shortcut)
        shortcutItem = nil
    }

    func applicationWillTerminate(_ application: UIApplication) {
        UIApplication.shared.isIdleTimerDisabled = false
        
        guard let key = FIRAuth.auth()?.currentUser?.uid else { return }
        GameHandler.instance.clearCurrentGamesFromFirebaseDB(forKey: key)
        
        self.saveContext()
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    
    func applicationWillResignActive(_ application: UIApplication) {  }
    func applicationDidEnterBackground(_ application: UIApplication) {  }
    func applicationWillEnterForeground(_ application: UIApplication) {  }
    
    /// Handler for quick action launch items
    /// - parameter shortcutItem: The UIApplicationShortcutItem the user selected
    /// - returns: A Boolean value, indicating whether the operation was successful or not
    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        enum Shortcut: String {
            case startGame = "com.CraunicProductions.MysticCompanion.StartGame"
            case joinGame = "com.CraunicProductions.MysticCompanion.JoinGame"
        }
        
        var quickActionHandled = false
        if let shortcutType = Shortcut.init(rawValue: shortcutItem.type) {
            var userIsHostingGame: Bool {
                switch shortcutType {
                case .startGame: return true
                case .joinGame: return false
                }
            }
            
            if FIRAuth.auth()?.currentUser?.uid != nil {
                guard let homeVC = window?.rootViewController as? HomeVC else { return false }
                homeVC.gameShouldAutoStart = true
                homeVC.userIsHostingGame = userIsHostingGame
//                homeVC.firManager.checkUsername(forKey: FIRAuth.auth()?.currentUser?.uid)
                homeVC.autoStartGame(userIsHosting: userIsHostingGame)
                quickActionHandled = true
            }
        }
        
        return quickActionHandled
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MysticCompanion")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, FIRMessagingDelegate {
    func removeNotification(withIdentifier identifier: String) {  }
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {  }
}

extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {  }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {  }
}
