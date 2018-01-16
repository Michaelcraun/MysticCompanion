//
//  UIViewControllerExtension.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/13/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

extension UIViewController {
    func shouldPresentLoadingView(_ status: Bool) {
        var fadeView: UIView?
        
        if status == true {
            fadeView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            fadeView?.backgroundColor = .black
            fadeView?.alpha = 0
            fadeView?.tag = 5050
            
            let spinner = UIActivityIndicatorView()
            spinner.color = .white
            spinner.activityIndicatorViewStyle = .whiteLarge
            spinner.center = view.center
            
            view.addSubview(fadeView!)
            fadeView?.addSubview(spinner)
            
            spinner.startAnimating()
            fadeView?.fadeAlphaTo(0.7, withDuration: 0.2)
        } else {
            for subview in view.subviews {
                if subview.tag == 5050 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subview.alpha = 0
                    }, completion: { (finished) in
                        subview.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    func checkTheme() {
        let defaults = UserDefaults.standard
        let userTheme = defaults.string(forKey: "theme")
        switch userTheme {
        case "drabGray"?: theme = .drabGray
        case "pastelBlue"?: theme = .pastelBlue
        case "pastelPurple"?: theme = .pastelPurple
        case "pastelYellow"?: theme = .pastelYellow
        default: theme = .pastelGreen
        }
    }
    
    func shareGame(withWinners winnersArray: [String]) {
        var isWinner: Bool {
            var _isWinner = false
            for winner in winnersArray {
                if winner == Player.instance.username {
                    _isWinner = true
                    break
                }
            }
            return _isWinner
        }
        
        let shareURL = "https://itunes.apple.com/us/app/mysticcompanion/id1249561021?mt=8"
        var shareMessage: String {
            switch isWinner {
            case true: return "I won a game of Mystic Vale with my friends using #MysticCompanion. You should come play with us!"
            case false: return "I played a game of Mystic Vale with my friends using #MysticCompanion. You should come play with us!"
            }
        }
        
        let activityVC = UIActivityViewController(activityItems: [shareURL, shareMessage], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
}
