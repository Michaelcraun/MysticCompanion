//
//  TrackerView.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/8/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import GMStepper

class TrackerView: UIView {
    /// An enumeration of tracker types used in the setup of trackers on the GameVC
    enum TrackerType {
        case animal
        case decay
        case forest
        case growth
        case mana
        case sky
        case victory
        case wild
        static let allTrackerTypes: [TrackerType] = [.animal, .decay, .forest, .growth, .mana, .sky, .victory, .wild]
        
        /// The UIImage associated with the TrackerType
        var icon: UIImage {
            switch self {
            case .animal: return #imageLiteral(resourceName: "animal")
            case .decay: return #imageLiteral(resourceName: "decay")
            case .forest: return #imageLiteral(resourceName: "forest")
            case .growth: return #imageLiteral(resourceName: "growth")
            case .mana: return #imageLiteral(resourceName: "mana")
            case .sky: return #imageLiteral(resourceName: "sky")
            case .victory: return #imageLiteral(resourceName: "victory")
            case .wild: return #imageLiteral(resourceName: "wild")
            }
        }
        
        /// The primary color associated with the TrackerType
        var primaryColor: UIColor {
            switch self {
            case .animal: return UIColor(red: 120/255, green: 89/255, blue: 59/255, alpha: 0.5)
            case .decay: return UIColor(red: 199/255, green: 73/255, blue: 70/255, alpha: 0.5)
            case .forest: return UIColor(red: 82/255, green: 151/255, blue: 116/255, alpha: 0.5)
            case .growth: return UIColor(red: 100/255, green: 126/255, blue: 108/255, alpha: 0.5)
            case .mana: return UIColor(red: 156/255, green: 213/255, blue: 233/255, alpha: 0.5)
            case .sky: return UIColor(red: 182/255, green: 143/255, blue: 53/255, alpha: 0.5)
            case .victory: return UIColor(red: 116/255, green: 189/255, blue: 187/255, alpha: 0.5)
            case .wild: return UIColor(red: 132/255, green: 91/255, blue: 150/255, alpha: 0.5)
            }
        }
        
        /// The secondary color associated with the TrackerType
        var secondaryColor: UIColor {
            switch self {
            case .animal: return UIColor(red: 158/255, green: 127/255, blue: 96/255, alpha: 0.5)
            case .decay: return UIColor(red: 227/255, green: 112/255, blue: 102/255, alpha: 0.5)
            case .forest: return UIColor(red: 109/255, green: 179/255, blue: 144/255, alpha: 0.5)
            case .growth: return UIColor(red: 108/255, green: 184/255, blue: 149/255, alpha: 0.5)
            case .mana: return UIColor(red: 209/255, green: 236/255, blue: 242/255, alpha: 0.5)
            case .sky: return UIColor(red: 229/255, green: 180/255, blue: 46/255, alpha: 0.5)
            case .victory: return UIColor(red: 205/255, green: 230/255, blue: 235/255, alpha: 0.5)
            case .wild: return UIColor(red: 162/255, green: 123/255, blue: 169/255, alpha: 0.5)
            }
        }
    }
    
    var type: TrackerType!
    let iconView = CircleView()
    let iconView2 = CircleView()
    let currentStepper = GMStepper()
    let constantStepper = GMStepper()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
        self.backgroundColor = type.secondaryColor
        self.clipsToBounds = true
        
        layoutTracker()
    }
    
    /// The initializer for trackers
    /// - parameter type: The specific TrackerType associated with the tracker
    func initTrackerOfType(_ type: TrackerType) { self.type = type }
    
    /// Configures the specified tracker to display the following:
    /// - The type of tracker it is (via the icon at the top and bottom)
    /// - A GMStepper for the current value of the tracker
    /// - A GMStepper for the constant vaule of the tracker (if the tracker isn't the VP tracker)
    func layoutTracker() {
        let trackerWidth = self.frame.width
        let iconWidth = trackerWidth / 4
        var stepperSpace: CGFloat {
            switch type {
            case .victory: return self.frame.height - iconWidth * 2
            default: return (self.frame.height - iconWidth * 2) / 2
            }
        }
        
        iconView.addImage(type.icon, withSizeModifier: 10)
        iconView.backgroundColor = type.secondaryColor
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconView2.addImage(type.icon, withSizeModifier: 10)
        iconView2.backgroundColor = type.secondaryColor
        iconView2.transform = iconView2.transform.rotated(by: .pi/1)
        iconView2.translatesAutoresizingMaskIntoConstraints = false
        
        currentStepper.buttonsBackgroundColor = type.secondaryColor
        currentStepper.labelBackgroundColor = type.primaryColor
        currentStepper.labelFont = UIFont(name: fontFamily, size: 15)!
        currentStepper.maximumValue = 500
        currentStepper.translatesAutoresizingMaskIntoConstraints = false
        
        constantStepper.buttonsBackgroundColor = type.secondaryColor
        constantStepper.labelBackgroundColor = type.primaryColor
        constantStepper.labelFont = UIFont(name: fontFamily, size: 15)!
        constantStepper.maximumValue = 500
        constantStepper.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(iconView)
        self.addSubview(iconView2)
        self.addSubview(currentStepper)
        
        iconView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: iconWidth).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: iconWidth).isActive = true
        
        iconView2.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        iconView2.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        iconView2.heightAnchor.constraint(equalToConstant: iconWidth).isActive = true
        iconView2.widthAnchor.constraint(equalToConstant: iconWidth).isActive = true
        
        currentStepper.topAnchor.constraint(equalTo: iconView.bottomAnchor).isActive = true
        currentStepper.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        currentStepper.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        currentStepper.heightAnchor.constraint(equalToConstant: stepperSpace).isActive = true
        
        if type != .victory {
            self.addSubview(constantStepper)
            
            constantStepper.topAnchor.constraint(equalTo: currentStepper.bottomAnchor).isActive = true
            constantStepper.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            constantStepper.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            constantStepper.heightAnchor.constraint(equalToConstant: stepperSpace).isActive = true
        }
    }
}
