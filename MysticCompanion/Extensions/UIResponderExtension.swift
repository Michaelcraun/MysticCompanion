//
//  UIResponderExtension.swift
//  MysticCompanion
//
//  Created by Michael Craun on 1/7/18.
//  Copyright © 2018 Craunic Productions. All rights reserved.
//  Courtesy Brett Chapin! :D
//

import UIKit

extension UIResponder {
    func parentViewControllers() -> [UIViewController]? {
        var nextResponder = self
        var responders: [UIResponder] = [nextResponder]
        while let next = nextResponder.next {
            nextResponder = next
            responders.append(next)
        }
        
        return responders.filter({$0 is UIViewController}) as? [UIViewController]
    }
    
    func dismissPreviousViewControllers() {
        guard let viewControllers = self.parentViewControllers() else {
            return
        }
        
        for vc in viewControllers {
            if vc == viewControllers.last {
                break
            } else {
                vc.dismiss(animated: false, completion: nil)
            }
        }
    }
}
