//
//  CityInfo.swift
//  Weather
//
//  Created by Даниил on 23.02.25.
//

struct CityInfo: Codable {    
    let id: Int
    let name: String
    let state: String
    let country: String
    let coord: Coord
}
