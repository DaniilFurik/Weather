//
//  CityViewModel.swift
//  Weather
//
//  Created by Даниил on 22.02.25.
//

import Foundation
import CoreLocation

// MARK: - Constants

private enum Constants {

}

// MARK: - Protocol

protocol ICityViewModel {
    func loadCitiesData()
    
    var citiesData: (([CityListItem]) -> Void)? { get set }
    var showToast: ((String) -> Void)? { get set }
}

// MARK: - Class

final class CityViewModel: ICityViewModel {
    // MARK: - Properties
    
    var citiesData: (([CityListItem]) -> Void)?
    var showToast: ((String) -> Void)?
    
    private let service = WeatherService()
    private let locationManager = LocationManager()
}
 
extension CityViewModel {
    // MARK: - Methods
    
    func loadCitiesData() {
        if NetworkManager.shared.isConnected {
            locationManager.getCurrentLocation { [weak self] coordinate in
                if let coordinate {
                    // здесь очередь
                    self?.getCitiesWeather(coord: coordinate)
                } else {
                    self?.showToast?(GlobalConstants.coordinatesError)
                }
            }
        } else {
            showToast?(GlobalConstants.connectionError)
        }
    }
}
    
private extension CityViewModel {
    // MARK: - Private Methods
    
    func getCitiesWeather(coord: CLLocationCoordinate2D) {
        let queryParams = getQueryParams(coord: coord)
        
        service.getCurrentWeather(queryParams: queryParams) { [weak self] result in
            if let weather = self?.getFormattedCityWeather(result) {
                self?.citiesData?([weather])
            } else {
                self?.showToast?(GlobalConstants.unknownError)
            }
        }
    }
    
    func getFormattedCityWeather(_ weather: WeatherResponse?) -> CityListItem? {
        if let weather {
            return CityListItem(
                name: weather.name,
                temp: weather.main.temp,
                icon: weather.weather[.zero].icon
            )
        }
        
        return nil
    }
    
    func getQueryParams(coord: CLLocationCoordinate2D) -> String {
        return "?\(GlobalConstants.unitsParam)&\(GlobalConstants.latitudeParam)\(coord.latitude)&\(GlobalConstants.longitudeeParam)\(coord.longitude)&\(GlobalConstants.appIDParam)"
    }
}

