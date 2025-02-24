//
//  LocationManager.swift
//  Weather
//
//  Created by Даниил on 17.02.25.
//

import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private var completion: ((CLLocationCoordinate2D?, Bool) -> Void)?
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            completion?(location.coordinate, false)
            locationManager.stopUpdatingLocation() // Останавливаем обновления после получения данных
            completion = nil // Обнуляем, чтобы избежать утечек памяти
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorization() // Перепроверяем статус при изменении
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(GlobalConstants.connectionError): \(error.localizedDescription)")
        completion?(nil, false)
        completion = nil
    }
}

extension LocationManager {
    // MARK: - Methods
    
    func getCurrentLocation(completion: @escaping (CLLocationCoordinate2D?, Bool) -> Void) {
        self.completion = completion
        checkAuthorization()
    }
    
    private func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() // Запрос на геолокацию
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation() // Начинаем получать координаты
        case .denied, .restricted:
            print(GlobalConstants.noLocationAccess)
            completion?(nil, true)
            completion = nil
        @unknown default:
            break
        }
    }
}
