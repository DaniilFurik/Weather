//
//  CityViewModel.swift
//  Weather
//
//  Created by Даниил on 22.02.25.
//

import Foundation
import CoreLocation

// MARK: - Protocol

protocol ICityViewModel {
    func loadCitiesData()
    func saveCurrentCity(cityId: Int)
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
    private var citiesInfo = [CityInfo]()
}
 
extension CityViewModel {
    // MARK: - Methods
    
    func loadCitiesData() {
        if NetworkManager.shared.isConnected {
            startDispatchGroup()
        } else {
            showToast?(GlobalConstants.connectionError)
        }
    }
    
    func saveCity(city: CityInfo) {
        StorageManager.shared.saveCity(city: city)
        loadCitiesData()
    }
    
    func saveCurrentCity(cityId: Int) {
        let currentCity = citiesInfo.first { $0.id == cityId}
        StorageManager.shared.saveCurrentCity(city: currentCity)
    }
    
    func searchCities(name: String, completion: @escaping ([CityInfo]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let jsonArray = self.getCitiesArray()
            var matchedCities = [CityInfo]()
            
            for cityDict in jsonArray {
                if let cityName = cityDict["name"] as? String,
                   cityName.lowercased().contains(name.lowercased()) {
                    
                    // Декодируем только найденные элементы
                    if let jsonData = try? JSONSerialization.data(withJSONObject: cityDict),
                       let city = try? JSONDecoder().decode(CityInfo.self, from: jsonData) {
                        if !self.cities.map({ $0.id }).contains(city.id) { // если нет еще такого id
                            matchedCities.append(city)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(matchedCities)
            }
        }
    }
}
    
private extension CityViewModel {
    // MARK: - Private Methods
    
    func getCitiesWeather(cityId: Int) {
        let queryParams = getQueryParams(cityId: cityId)
        
        service.getCurrentWeather(queryParams: queryParams) { [weak self] result in
            if let weather = self?.getFormattedCityWeather(result) {
                self?.cities.append(weather)
            } else {
                self?.showToast?(GlobalConstants.unknownError)
            }
            
            self?.dispatchGroup.leave()
        }
    }
    
    func getFormattedCityWeather(_ weather: WeatherResponse?) -> CityListItem? {
        if let weather {
            return CityListItem(
                name: weather.name,
                country: weather.sys.country,
                temp: weather.main.temp,
                icon: weather.weather[.zero].icon,
                id: weather.id
            )
        }
        
        return nil
    }
    
    func getQueryParams(cityId: Int) -> String {
        return "?\(GlobalConstants.unitsParam)&\(GlobalConstants.cityIDParam)\(cityId)&\(GlobalConstants.appIDParam)"
    }
    
    func getCitiesArray() -> [[String:Any]] {
        guard let path = Bundle.main.path(forResource: "city.list", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            return [[:]]
        }
        
        return jsonArray
    }
    
    func startDispatchGroup() {
        cities = []
        citiesInfo = StorageManager.shared.getCities()
        
        for item in citiesInfo {
            self.dispatchGroup.enter()
            self.queue.async {
                self.getCitiesWeather(cityId: item.id)
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            if var cities = self?.cities {
                cities.sort { $0.name < $1.name }
                self?.citiesData?(cities)
            }
        }
    }
}
