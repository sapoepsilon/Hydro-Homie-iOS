//
//  LocationService.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/27/21.
//

import Foundation
import CoreLocation

class locationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if manager.authorizationStatus == .authorizedWhenInUse {
            print("authorized")
        } else {
            print("not authorized")
            manager.requestWhenInUseAuthorization()
        }
    }
}
