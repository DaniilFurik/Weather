//
//  StorageManager.swift
//  Racing2D
//
//  Created by Даниил on 13.12.24.
//

import UIKit

final class StorageManager {
    // MARK: - Properties
    
    static let shared = StorageManager()
    
    private init() { }
}

extension StorageManager {
    // MARK: - Methods
    
    func saveCity(city: CityInfo) {
        var array = getCities()
        array.append(city)
        
        UserDefaults.standard.set(encodable: array, forKey: .keyCities)
    }
    
    func getCities() -> [CityInfo] {
        guard let list = UserDefaults.standard.get([CityInfo].self, forKey: .keyCities) else { return [] }
        
        return list
    }
    
    func getCurrentCity() -> CityInfo? {
        guard let city = UserDefaults.standard.get(CityInfo.self, forKey: .keyCurrentCity) else { return nil }
        
        return city
    }
    
    func saveCurrentCity(city: CityInfo?) {
        UserDefaults.standard.set(encodable: city, forKey: .keyCurrentCity)
    }
}
