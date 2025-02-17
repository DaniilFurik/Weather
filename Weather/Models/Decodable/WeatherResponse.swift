//
//  WeatherResponse.swift
//  Weather
//
//  Created by Даниил on 11.02.25.
//

final class WeatherResponse: Decodable {
    let name: String
    let weather: [Weather]
    let dt: Int
    let sys: Sys
    let coord: Coord
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let timezone: Int
    let id: Int
    let cod: Int
}
