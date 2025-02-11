//
//  WeatherResponse.swift
//  Weather
//
//  Created by Даниил on 11.02.25.
//

final class ForecastResponse: Decodable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [Forecast]
    let city: City
}
