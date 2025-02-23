//
//  UserDefaults+Extensions.swift
//  Racing2D
//
//  Created by Даниил on 13.12.24.
//

import UIKit

extension UserDefaults {
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }
    
    func get<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        
        return nil
    }
}
