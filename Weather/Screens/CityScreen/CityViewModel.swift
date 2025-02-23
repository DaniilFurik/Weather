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
    func saveCity(city: CityInfo)
    func searchCities(name: String, completion: @escaping ([CityInfo]) -> Void)
    
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
    
    private let queue = DispatchQueue(label: .empty, attributes: .concurrent)
    private let dispatchGroup = DispatchGroup()
    
    private var cities = [CityListItem]()
}
 
extension CityViewModel {
    // MARK: - Methods
    
    func loadCitiesData() {
        if NetworkManager.shared.isConnected {
            locationManager.getCurrentLocation { [weak self] coordinate in
                if let coordinate {
                    self?.startDispatchGroup(coord: coordinate)
                } else {
                    self?.showToast?(GlobalConstants.coordinatesError)
                }
            }
        } else {
            showToast?(GlobalConstants.connectionError)
        }
    }
    
    func saveCity(city: CityInfo) {
        StorageManager.shared.saveCity(city: city)
        
        loadCitiesData()
    }
    
    func searchCities(name: String, completion: @escaping ([CityInfo]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let path = Bundle.main.path(forResource: "city.list", ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
                  let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            var matchedCities = [CityInfo]()
            
            for cityDict in jsonArray {
                guard let cityName = cityDict["name"] as? String,
                      cityName.lowercased().contains(name.lowercased()) else {
                    continue
                }
                
                // Декодируем только найденные элементы
                if let jsonData = try? JSONSerialization.data(withJSONObject: cityDict),
                   let city = try? JSONDecoder().decode(CityInfo.self, from: jsonData) {
                    matchedCities.append(city)
                }
            }
            
            matchedCities = matchedCities.filter { !self.cities.map { $0.name }.contains($0.name) }
            
            DispatchQueue.main.async {
                completion(matchedCities)
            }
        }
    }
}
    
private extension CityViewModel {
    // MARK: - Private Methods
    
    func getCitiesWeather(coord: CLLocationCoordinate2D) {
        let queryParams = getQueryParams(coord: coord)
        
        service.getCurrentWeather(queryParams: queryParams) { [weak self] result in
            if let weather = self?.getFormattedCityWeather(result) {
                self?.cities.append(weather)
                self?.dispatchGroup.leave()
            } else {
                self?.showToast?(GlobalConstants.unknownError)
            }
        }
    }
    
    func getFormattedCityWeather(_ weather: WeatherResponse?) -> CityListItem? {
        if let weather {
            return CityListItem(
                name: weather.name,
                country: weather.sys.country,
                temp: weather.main.temp,
                icon: weather.weather[.zero].icon
            )
        }
        
        return nil
    }
    
    func getQueryParams(coord: CLLocationCoordinate2D) -> String {
        return "?\(GlobalConstants.unitsParam)&\(GlobalConstants.latitudeParam)\(coord.latitude)&\(GlobalConstants.longitudeeParam)\(coord.longitude)&\(GlobalConstants.appIDParam)"
    }
    
    func startDispatchGroup(coord: CLLocationCoordinate2D) {
        cities = []
        
        let array = StorageManager.shared.getCities()
        
        for item in array {
            let coord = CLLocationCoordinate2D(latitude: item.coord.lat, longitude: item.coord.lon)
            self.dispatchGroup.enter()
            self.queue.async {
                self.getCitiesWeather(coord: coord)
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            if let cities = self?.cities {
                self?.citiesData?(cities)
            }
        }
    }
}
