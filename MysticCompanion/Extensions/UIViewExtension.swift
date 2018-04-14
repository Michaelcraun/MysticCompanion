//
//  UIViewExtension.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/6/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

extension UIView {
    /// Fades the alpha of a specified view to a specific alpha value over a specific duration
    /// - parameter alpha: A CGFloat value representing the desired alpha (must be between 0.0 and 1.0)
    /// - parameter duration: A TimeInterval value representing the desired duration
    func fadeAlphaTo(_ alpha: CGFloat, withDuration duration: TimeInterval, andDelay delay: TimeInterval = 0.0) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            self.alpha = alpha
        }, completion: nil)
    }
    
    /// Fades the alpha of a specified view to 0 and then removes it from it's superView
    func fadeAlphaOut() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { (finished) in
            self.removeFromSuperview()
        })
    }
    
    @objc private func keyboardWillChange(notification: NSNotification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let curveFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curveFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: UIViewKeyframeAnimationOptions(rawValue: curve),
                                animations: {
                                    self.frame.origin.y += deltaY
        }, completion: nil)
    }
    
    /// Adds a tap gesture to the specified view to dismiss the keyboard
    func addTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:)))
        self.addGestureRecognizer(tap)
    }
    
    /// Dismisses the keyboard when the user taps the view
    /// - parameter sender: The UITapGestureRecognizer associated with the function
    @objc private func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    /// Adds a blur effect to the specified view's foreground
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.tag = 1001
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(blurEffectView)
    }
}
