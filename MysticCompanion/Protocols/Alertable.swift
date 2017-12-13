//
//  Alertable.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 12/5/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

protocol Alertable {  }

extension Alertable where Self: UIViewController {
    func showAlert(withTitle title: String, andMessage message: String) {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.tag = 1001
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurEffectView)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            for subview in self.view.subviews {
                if subview.tag == 1001 {
                    subview.removeFromSuperview()
                }
                
                if alertController.message == "You ended the game. Please wait for the other players to complete their turns." {
                    self.performSegue(withIdentifier: "showEndGame", sender: nil)
                }
            }
        })
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
