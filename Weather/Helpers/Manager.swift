//
//  Manager.swift
//  Racing2D
//
//  Created by Даниил on 26.11.24.
//

import Foundation
import UIKit

final class Manager {
    // MARK: - Properties
    
    static let shared = Manager()
    
    // MARK: - Livecycle
    
    private init() { }
}

extension Manager {
    // MARK: - Methods
    
    func getFormattedDate(for date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func getDate(from string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}
