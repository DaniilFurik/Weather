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
    private var completion: ((CLLocationCoordinate2D?) -> Void)?
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            completion?(location.coordinate)
            locationManager.stopUpdatingLocation() // Останавливаем обновления после получения данных
            completion = nil // Обнуляем, чтобы избежать утечек памяти
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorization() // Перепроверяем статус при изменении
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения координат: \(error.localizedDescription)")
        completion?(nil)
        completion = nil
    }
}

extension LocationManager {
    // MARK: - Methods
    
    func getCurrentLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
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
            print("Доступ запрещен пользователем или ограничен")
            completion?(nil)
            completion = nil
        @unknown default:
            break
        }
    }
}
