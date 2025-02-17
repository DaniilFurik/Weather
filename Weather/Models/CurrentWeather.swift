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
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let hum: Int
    let windSpeed: Double
    let windDeg: Int
    let dateTime: Date
    let description: String
    let icon: String
    let sunrise: Date
    let sunset: Date
}
