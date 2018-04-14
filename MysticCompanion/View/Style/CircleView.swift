//
//  PlayerIcon.swift
//  MysticValeCompanion
//
//  Created by Michael Craun on 8/7/17.
//  Copyright © 2017 Michael Craun. All rights reserved.
//

import UIKit
@IBDesignable

class CircleView: UIView {
    let imageView = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    /// Centers a specific image to the CircleView that is of equal width and height (modified by a specific size
    /// modifier) to the CircleView
    /// - parameter image: The UIImage assigned to the CircleView
    /// - parameter sizeMod: A CGFloat value representing the size to which the image is modified by
    func addImage(_ image: UIImage, withSizeModifier sizeMod: CGFloat) {
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -sizeMod).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -sizeMod).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
