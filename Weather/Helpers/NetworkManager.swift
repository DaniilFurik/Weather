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
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    private var isConnected: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.onStatusChange?(self.isConnected)
            }
        }
    }
    
    var onStatusChange: ((Bool) -> Void)?
    
    // MARK: - Livecycle
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}
