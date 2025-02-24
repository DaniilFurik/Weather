//
//  CurrentWeather.swift
//  Weather
//
//  Created by Даниил on 16.02.25.
//

import Foundation

struct CurrentWeather {
    let cityName: String
    let countryCode: String
    let temp: Double
    let tempFeelsLike: Double
    let pressure: Double
    let hum: Int
    let windSpeed: Double
    let windDeg: Int
    let dateTime: String
    let description: String
    let icon: String
    let sunrise: String
    let sunset: String
    let isCurrentCity: Bool
}
