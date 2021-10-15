//
//  APIManager.swift
//  WeatherForecasting
//
//  Created by MAC on 15/10/2021.
//


import Foundation
import Alamofire

class APIManager {
    
    static let client = APIManager()
    
    fileprivate let apiKey = "758e36caf6mshb4d6bc364f9aa74p1ff31ejsne095527c8a77"
    
    typealias CurrentWeatherCompletionHandler = (CurrentWeather?, OpenWeatherMapError?) -> Void
    
    func getCurrentWeather(at coordinate: Coordinate, completionHandler completion: @escaping CurrentWeatherCompletionHandler) {

        guard let url = URL(string: Constants.getCurrentWeather) else {
            completion(nil, .invalidUrl)
            return
        }

        let parameters: Parameters = [
            "lat": String(Coordinate.sharedInstance.latitude),
            "lon": String(Coordinate.sharedInstance.latitude)
        ]
        
        let headers: HTTPHeaders = [
          "x-rapidapi-host": "community-open-weather-map.p.rapidapi.com",
          "x-rapidapi-key": "758e36caf6mshb4d6bc364f9aa74p1ff31ejsne095527c8a77"
        ]

        AF.request(url, parameters: parameters, headers: headers).responseJSON { response in
            
            
            guard let data = response.data else {return}
            do {
                let weather = try JSONDecoder().decode(CurrentWeather.self, from: data)
                DispatchQueue.main.async {
                    completion(weather, nil)
                }
            }
            catch let jsonErr {
                print("failed to decode", jsonErr)
            }

        }
    }
    
}
