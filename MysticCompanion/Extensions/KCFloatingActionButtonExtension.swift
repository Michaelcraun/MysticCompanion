//
//  KCFloatingActionButtonExtension.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/11/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import KCFloatingActionButton

extension KCFloatingActionButton {
    func setPaddingY() {
        var yPadding: CGFloat {
            switch PREMIUM_PURCHASED {
            case true: return 20
            default: return 70
            }
        }
        
        self.paddingY = yPadding
    }
}
