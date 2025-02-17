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
    var forecastWeather: ((ForecastResponse) -> Void)? { get set }
}

// MARK: - Class

final class WeatherViewModel: IWeatherViewModel {
    // MARK: - Properties
        
    var currentWeather: ((CurrentWeather) -> Void)?
    var forecastWeather: ((ForecastResponse) -> Void)?
    
    private let service = WeatherService()
    private let locationManager = LocationManager()
}
 
extension WeatherViewModel {
    // MARK: - Methods
    
    func loadWeatherData() {
        locationManager.getCurrentLocation { coordinate in
            if let coordinate {
                if true { // Check internet connection
                    self.getCurrentWeather(coord: coordinate)
                    self.getForecastWeather(coord: coordinate)
                } else {
                    // show internet error
                }
            } else {
                print("Не удалось получить координаты")
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
                // show error
            }
        }
    }
    
    func getForecastWeather(coord: CLLocationCoordinate2D) {
        let queryParams = getQueryParams(coord: coord)
        
        service.getForecastWeather(queryParams: queryParams) { [weak self] result in
            if let result {
                self?.forecastWeather?(result)
            } else {
                // show error
            }
        }
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
