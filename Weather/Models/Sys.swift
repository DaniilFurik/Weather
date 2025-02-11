//
//  Sys.swift
//  Weather
//
//  Created by Даниил on 11.02.25.
//

final class Sys: Decodable {
    let country: String
    let sunrise: Int
    let sunset: Int
}
