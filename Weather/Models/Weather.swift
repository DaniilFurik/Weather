//
//  Weather.swift
//  Weather
//
//  Created by Даниил on 11.02.25.
//

final class Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
