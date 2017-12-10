//
//  HomeMapKit.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/6/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import MapKit

extension HomeVC: CLLocationManagerDelegate {
    func checkLocationAuthStatus() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthStatus()
    }
}
