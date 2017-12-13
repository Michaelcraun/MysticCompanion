//
//  NetworkIndicator.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/13/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class NetworkIndicator: NSObject {
    private static var loadingCount = 0

    class func networkOperationStarted() {
        if loadingCount == 0 { UIApplication.shared.isNetworkActivityIndicatorVisible = true }
        loadingCount += 1
    }

    class func networkOperationFinished() {
        if loadingCount > 0 { loadingCount -= 1 }
        if loadingCount == 0 { UIApplication.shared.isNetworkActivityIndicatorVisible = false }
    }
}

