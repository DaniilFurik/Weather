//
//  NetworkManager.swift
//  Weather
//
//  Created by Даниил on 18.02.25.
//

import Network

final class NetworkManager {
    // MARK: - Properties
    
    static let shared = NetworkManager()
    var isConnected = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    // MARK: - Livecycle
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}
