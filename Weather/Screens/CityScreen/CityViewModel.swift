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
    
    private let queue = DispatchQueue(label: .empty, attributes: .concurrent)
    private let dispatchGroup = DispatchGroup()
    
    private var cities = [CityListItem]()
    private var citiesInfo = [CityInfo]()
    private var jsonArray: [[String: Any]] = []
    
    init() {
        loadJSON()
    }
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
            var filteredCities = [CityInfo]()
            
            for cityDict in self.jsonArray {
                if let cityName = cityDict["name"] as? String,
                   cityName.lowercased().contains(name.lowercased()) {
                    
                    // Декодируем только найденные элементы
                    if let jsonData = try? JSONSerialization.data(withJSONObject: cityDict),
                       let city = try? JSONDecoder().decode(CityInfo.self, from: jsonData) {
                        if !self.cities.map({ $0.id }).contains(city.id) { // если нет еще такого id
                            filteredCities.append(city)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(filteredCities)
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
            if let cities = self?.cities {
                // сортируем в порядке добавления
                let orderMap = Dictionary(uniqueKeysWithValues: (self?.citiesInfo.enumerated().map { ($1.id, $0) })!)
                let sorted = cities.sorted { orderMap[$0.id, default: Int.max] < orderMap[$1.id, default: Int.max] }
                
                self?.citiesData?(sorted)
            }
        }
    }
    
    func loadJSON() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let path = Bundle.main.path(forResource: "city.list", ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
                  let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                return
            }
            
            self?.jsonArray = jsonArray
        }
    }
}
