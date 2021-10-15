//
//  Coordinate.swift
//  WeatherForecasting
//
//  Created by MAC on 15/10/2021.
//

import Foundation
import CoreLocation

struct Coordinate {
    
    static var sharedInstance = Coordinate(latitude: 0.0, longitude: 0.0)
    
    static let locationManager = CLLocationManager()
    
    var latitude: Double
    var longitude: Double
    
    typealias CheckLocationPermissionsCompletionHandler = (Bool) -> Void
    static func checkForGrantedLocationPermissions(completionHandler completion: @escaping CheckLocationPermissionsCompletionHandler) {
        let locationPermissionsStatusGranted = CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        
        if locationPermissionsStatusGranted {
            let currentLocation = locationManager.location
            Coordinate.sharedInstance.latitude = (currentLocation?.coordinate.latitude)!
            Coordinate.sharedInstance.longitude = (currentLocation?.coordinate.longitude)!
        }
        
        completion(locationPermissionsStatusGranted)
    }
    
    
}

