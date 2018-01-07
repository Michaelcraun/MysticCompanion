//
//  CustomSegues.swift
//  MysticCompanion
//
//  Created by Michael Craun on 1/7/18.
//  Copyright © 2018 Craunic Productions. All rights reserved.
//

import UIKit

class SlideToLeft: UIStoryboardSegue {
    override func perform() {
        let destination = self.destination
        let source = self.source
        let containerView = source.view.superview
        
        destination.view.transform = CGAffineTransform(translationX: -250, y: 0)
        containerView?.addSubview(destination.view)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            destination.view.transform = CGAffineTransform.identity
        }, completion: { finished in
            source.present(destination, animated: false, completion: nil)
        })
    }
}

class UnwindSlideToLeft: UIStoryboardSegue {
    override func perform() {
        let source = self.source
        
        source.view.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            source.view.transform = CGAffineTransform(translationX: -250, y: 0)
        }, completion: { finished in
            source.dismiss(animated: false, completion: nil)
        })
    }
}
