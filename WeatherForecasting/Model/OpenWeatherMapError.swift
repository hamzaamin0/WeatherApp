//
//  OpenWeatherMapError.swift
//  WeatherForecasting
//
//  Created by MAC on 15/10/2021.
//

import Foundation

enum OpenWeatherMapError: Error {
    case requestFailed
    case responseUnsuccessful
    case invalidaData
    case jsonConversionFailure
    case invalidUrl
    case jsonParsingFailure
}
