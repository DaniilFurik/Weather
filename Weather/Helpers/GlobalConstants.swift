//
//  GlobalConstants.swift
//  Weather
//
//  Created by Даниил on 10.02.25.
//

import Foundation

final class GlobalConstants {
    static let appID = "a4c07d539a160c1d5ec3a597937067ca"
    
    static let imgURL = "https://openweathermap.org/img/wn/"
    static let imgPostfix = "@2x.png"
    
    static let connectionError = "No internet connection"
    static let unknownError = "Something went wrong"
    static let coordinatesError = "Can't get coordinates"
    
    static let noLocationAccess = "Need location access. Please go to settings"
    
    static let dateFormat = "dd MMM yyyy HH'h' mm'm' ss's'"
    static let timeFormat = "HH'h' mm'm' ss's'"
    static let hourFormat = "HH'h'"
    static let dayOfWeekFormat = "E, d"
    
    static let degreesCelsius = "°C"
    
    static let verticalSpacing: CGFloat = 16
    static let horizontalSpacing: CGFloat = 16
}

//https://openweathermap.org/current
//https://openweathermap.org/forecast5
//https://openweathermap.org/api/weathermaps
//https://openweathermap.org/api/air-pollution
//https://openweathermap.org/api/geocoding-api

//https://openweathermap.org/weather-conditions
//https://openweathermap.org/img/wn/10d@2x.png
