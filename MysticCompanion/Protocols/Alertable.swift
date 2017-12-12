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
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurEffectView)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            blurEffectView.fadeAlphaOut()
        })
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func addBlurEffect() {
        
    }
}
