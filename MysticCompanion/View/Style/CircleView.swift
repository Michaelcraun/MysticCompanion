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
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    func addBorder() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
    }
    
    func addImage(_ image: UIImage, withWidthModifier widthMod: CGFloat) {
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -widthMod).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -widthMod).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
