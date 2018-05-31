//
//  MailManager.swift
//  MysticCompanion
//
//  Created by Michael Craun on 4/18/18.
//  Copyright © 2018 Craunic Productions. All rights reserved.
//

import Foundation
import MessageUI

class MailManager: NSObject, MFMailComposeViewControllerDelegate {
    var delegate: UIViewController!
    var canSendMail = false
    
    /// Should be called when an email button appears and sets canSendMail, which can be checked when the user
    /// taps buttons to send mail.
    func checkCanSendMail() {
        if MFMailComposeViewController.canSendMail() {
            canSendMail = true
        } else {
            delegate.showAlert(.mailError)
        }
    }
    
    /// Constructs and displays an support email to Craunic Productions
    func sendSupportMail() {
        checkCanSendMail()
        
        if canSendMail {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["support@craunicproductions.com"])
            composeVC.setSubject("MysticCompanion Support")
            
            delegate.present(composeVC, animated: true, completion: nil)
        }
    }
    
    internal func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
