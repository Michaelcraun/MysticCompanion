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
    func addImage(_ image: UIImage, withSize size: CGFloat) {
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.anchorTo(self,
                           centerX: self.centerXAnchor,
                           centerY: self.centerYAnchor,
                           size: .init(width: size, height: size))
    }
}
