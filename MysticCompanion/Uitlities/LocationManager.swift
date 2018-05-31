//
//  LocationManager.swift
//  MysticCompanion
//
//  Created by Michael Craun on 4/18/18.
//  Copyright © 2018 Craunic Productions. All rights reserved.
//

import Foundation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    var delegate: UIViewController!
    var manager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override init() {
        super.init()
        
        checkLocationAuthStatus()
    }
    
    func checkLocationAuthStatus() {
        if CLLocationManager.locationServicesEnabled() {
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.startUpdatingLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
}
