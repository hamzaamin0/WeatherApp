//
//  TodaysWeatherViewController.swift
//  WeatherForecasting
//
//  Created by MAC on 15/10/2021.
//

import UIKit
import CoreLocation

class TodaysWeatherViewController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherConditionLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var precipitationLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var windDirectionLabel: UILabel!
    
    @IBOutlet var locationPermissionMessageLabel: UILabel!
    @IBOutlet var locationPermissionBGView: UIView!
    
    
    //MARK: Properties
    let locationManager = CLLocationManager()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkLocationPermissions()
    }
    
    //MARK: IBActions
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {

        let sharedText = "Hey! Wanna know about weather in your area?"
        let activityController = UIActivityViewController(activityItems: [sharedText], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    
    func getCurrentWeather() {
        toggleRefreshAnimation(on: true)
        toggleLocationPermissionBGView(flag: true)
        DispatchQueue.main.async {
            
            APIManager.client.getCurrentWeather(at: Coordinate.sharedInstance) {
                [unowned self] currentWeather, error in
                if let currentWeather = currentWeather {
                    
                    self.displayWeather(using: currentWeather)
                    self.toggleRefreshAnimation(on: false)
                }
            }
        }
    }
    
    func displayWeather(using weather: CurrentWeather) {
        
        if let city = weather.name {
            
            self.cityNameLabel.text = city
        }
        
        if let temprature = weather.main?.temp {
            
            self.temperatureLabel.text = "\(temprature)"
        }
        
        if let weatherCondition = weather.weather?[0].main {
            
            self.weatherConditionLabel.text = weatherCondition
        }
        
        if let humidity = weather.main?.humidity {
            
            self.humidityLabel.text = "\(humidity)"
        }
        
        if let precipitation = weather.main?.humidity {
            
            self.precipitationLabel.text = "\(precipitation)"
        }
        
        if let pressure = weather.main?.pressure {
            
            self.pressureLabel.text = "\(pressure)"
        }
        
        if let speed = weather.wind?.speed {
            
            self.windSpeedLabel.text = "\(speed)"
        }
        
        if let direction = weather.wind?.deg {
            
            self.windDirectionLabel.text = "\(direction)"
        }
        
//        if let city = weather.name {
//
//            self.weatherImageView.image = weather.icon
//        }
        
        
        
        
        
       
        
        
    }
    
    func toggleRefreshAnimation(on: Bool) {
        if on {
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        } else {
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    


}

extension TodaysWeatherViewController{
    
    func checkLocationPermissions() {
        Coordinate.checkForGrantedLocationPermissions() { [weak self] allowed in
            if allowed {
                self?.locationManager.requestLocation()
                self?.getCurrentWeather()
            } else {
                self?.askForLocationPermission()
            }
        }
    }
    
    private func askForLocationPermission(){


        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // The user has not yet made a choice regarding whether this app can use location services, then request permissions to use Location on foreground
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                self.displayLocationPermissionsDenied()
                // show alert
                let alert = UIAlertController(title: "Alert", message: Constants.turnOnLocation, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.requestLocation()
                self.getCurrentWeather()
            }
        } else {
            // Location services are not enabled
            self.displayLocationPermissionsDenied()
        }
    }
    
    
    func displayLocationPermissionsDenied() {
        
        toggleLocationPermissionBGView(flag: false)
        self.locationPermissionMessageLabel.text = Constants.locationPermissionDenied
    }
    
    func displayLocationPermissionsNotDeterminated() {
        toggleLocationPermissionBGView(flag: false)
        self.locationPermissionMessageLabel.text = Constants.requestLocationPermission
    }
    
    
    private func toggleLocationPermissionBGView(flag: Bool){
        
        if flag{
            locationPermissionBGView.isHidden = true
            
        }else {
            
            locationPermissionBGView.isHidden = false
        }
    }
    func manageLocationStatus(status: CLAuthorizationStatus) {
        switch(status) {
        case .notDetermined:
            self.displayLocationPermissionsNotDeterminated()
        case .restricted, .denied:
            self.displayLocationPermissionsDenied()
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.requestLocation()
            self.getCurrentWeather()
        }
    }
}

extension TodaysWeatherViewController: CLLocationManagerDelegate {
    
    // new location data is available
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        // update shaped instance
        Coordinate.sharedInstance.latitude = (manager.location?.coordinate.latitude)!
        Coordinate.sharedInstance.longitude = (manager.location?.coordinate.longitude)!
        // request current weather
        self.getCurrentWeather()
    }
    
    // the location manager was unable to retrieve a location value
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        Coordinate.checkForGrantedLocationPermissions() { allowed in
            if !allowed {
                self.toggleLocationPermissionBGView(flag: false)
            }
        }
    }
    
    // the authorization status for the application changed
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus){
        self.manageLocationStatus(status: status)
    }
}


