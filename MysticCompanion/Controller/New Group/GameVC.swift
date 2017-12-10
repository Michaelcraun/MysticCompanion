//
//  GameVC.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/28/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class GameVC: UIViewController {
    
    //MARK: Outlet variables
    let playerPanel = UIView()
    let currentPlayerLabel = UILabel()
    let currentPlayerVPLabel = UILabel()
    let gameVPLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutView()
    }
}
