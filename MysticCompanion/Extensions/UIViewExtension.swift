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

//-----------------------
// MARK: - Layout Methods
//-----------------------
extension UIView {
    /// Adds self to the specified view, constraining self the the view's edges, with a given padding
    /// - parameter view: The specified view to constrain self to
    /// - parameter padding: The specified padding to give the view
    func fillTo(_ view: UIView, padding: UIEdgeInsets = .zero) {
        view.addSubview(self)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right).isActive = true
    }
    
    /// Adds self to the specified view, if a view is specified, and applies the rest of the constraints, if specified
    /// - parameter view: The specified view to add self to
    /// - parameter top: The NSLyaoutYAxisAnchor to constrain self's topAnchor to
    /// - parameter bottom: The NSLayoutYAxisAnchor to constrain self's bottomAnchor to
    /// - parameter leading: The NSLayoutXAxisAnchor to constrain self's leadingAnchor to
    /// - parameter trailing: The NSLayoutXAxisAnchor to constrain self's trailingAnchor to
    /// - parameter centerX: The NSLayoutXAxisAnchor to constrain self's centerXAnchor to
    /// - parameter centerY: The NSLayoutYAxisAnchor to constrain self's centerYAnchor to
    /// - parameter padding: A UIEdgeInsets value that determines the constant of self's top, leading, bottom, and trailing constraints
    /// - parameter size: A CGSize value used to constrain self's width and height
    func anchorTo(_ view: UIView? = nil,
                  top: NSLayoutYAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil,
                  leading: NSLayoutXAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil,
                  centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil,
                  padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let view = view { view.addSubview(self) }
        if let top = top { topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true }
        if let leading = leading { leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true }
        if let trailing = trailing { trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true }
        if let bottom = bottom { bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true }
        
        if let centerX = centerX { centerXAnchor.constraint(equalTo: centerX).isActive = true }
        if let centerY = centerY { centerYAnchor.constraint(equalTo: centerY).isActive = true }
        
        if size.width != 0 { widthAnchor.constraint(equalToConstant: size.width).isActive = true }
        if size.height != 0 { heightAnchor.constraint(equalToConstant: size.height).isActive = true }
    }
}
