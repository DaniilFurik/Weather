//
//  City.swift
//  Weather
//
//  Created by Даниил on 11.02.25.
//

final class City: Decodable {
    let id: Int
    let name: String
    let coord: Coord
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}
