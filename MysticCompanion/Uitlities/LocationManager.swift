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
    private var manager = CLLocationManager()
    var delegate: UIViewController!
    var currentLocation: CLLocation?
    
    override init() {
        super.init()
        
        checkLocationAuthStatus()
    }
    
    private func checkLocationAuthStatus() {
        print("CLOUD: Checking location auth status...")
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.startUpdatingLocation()
        } else {
            checkLocationAuthStatus()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
}
