//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Даниил on 16.02.25.
//

import Foundation
import CoreLocation

// MARK: - Constants

private enum Constants {
    static let defaultParam = "?units=metric&appid=\(GlobalConstants.appID)"
}

// MARK: - Protocol

protocol IWeatherViewModel {
    func loadWeatherData()
    
    var currentWeather: ((CurrentWeather) -> Void)? { get set }
    var forecastWeather: (([ForecastWeather]) -> Void)? { get set }
    var showToast: ((String) -> Void)? { get set }
}

// MARK: - Class

final class WeatherViewModel: IWeatherViewModel {
    // MARK: - Properties
        
    var currentWeather: ((CurrentWeather) -> Void)?
    var forecastWeather: (([ForecastWeather]) -> Void)?
    var showToast: ((String) -> Void)?
    
    private let service = WeatherService()
    private let locationManager = LocationManager()
}
 
extension WeatherViewModel {
    // MARK: - Methods
    
    func loadWeatherData() {
        NetworkManager.shared.onStatusChange = { [weak self] isConnected in
            if isConnected {
                self?.locationManager.getCurrentLocation { [weak self] coordinate in
                    if let coordinate {
                        self?.getCurrentWeather(coord: coordinate)
                        self?.getForecastWeather(coord: coordinate)
                    } else {
                        self?.showToast?(GlobalConstants.coordinatesError)
                    }
                }
            } else {
                self?.showToast?(GlobalConstants.connectionError)
            }
        }
    }
}
    

private extension WeatherViewModel {
    // MARK: - Private Methods
    
    func getCurrentWeather(coord: CLLocationCoordinate2D) {
        let queryParams = getQueryParams(coord: coord)
        
        service.getCurrentWeather(queryParams: queryParams) { [weak self] result in
            if let weather = self?.getFormattedWeather(result) {
                self?.currentWeather?(weather)
            } else {
                self?.showToast?(GlobalConstants.unknownError)
            }
        }
    }
    
    func getForecastWeather(coord: CLLocationCoordinate2D) {
        let queryParams = getQueryParams(coord: coord)
        
        service.getForecastWeather(queryParams: queryParams) { [weak self] result in
            if let forecast = self?.getFormattedForecast(result) {
                self?.forecastWeather?(forecast)
            } else {
                self?.showToast?(GlobalConstants.unknownError)
            }
        }
    }
    
    func getFormattedForecast(_ forecast: ForecastResponse?) -> [ForecastWeather]? {
        if let forecast {
            var array = [ForecastWeather]()
            
            for item in forecast.list {
                array.append(ForecastWeather(
                    temp: item.main.temp,
                    hum: item.main.humidity,
                    dateTime: Date(timeIntervalSince1970: TimeInterval(item.dt)),
                    description: item.weather[.zero].description,
                    icon: item.weather[.zero].icon
                ))
            }
            
            return array
        }
        
        return nil
    }
    
    func getFormattedWeather(_ weather: WeatherResponse?) -> CurrentWeather? {
        if let weather {
            return CurrentWeather(
                cityName: weather.name,
                countryCode: weather.sys.country,
                temp: weather.main.temp,
                tempFeelsLike: weather.main.feelsLike,
                tempMin: weather.main.tempMin,
                tempMax: weather.main.tempMax,
                pressure: weather.main.pressure,
                hum: weather.main.humidity,
                windSpeed: weather.wind.speed,
                windDeg: weather.wind.deg,
                dateTime: Date(timeIntervalSince1970: TimeInterval(weather.dt)),
                description: weather.weather[.zero].description,
                icon: weather.weather[.zero].icon,
                sunrise: Date(timeIntervalSince1970: TimeInterval(weather.sys.sunrise)),
                sunset: Date(timeIntervalSince1970: TimeInterval(weather.sys.sunset))
            )
        }
        
        return nil
    }
    
    func getQueryParams(coord: CLLocationCoordinate2D) -> String {
        return Constants.defaultParam + "&lat=\(coord.latitude)&lon=\(coord.longitude)"
    }
}
