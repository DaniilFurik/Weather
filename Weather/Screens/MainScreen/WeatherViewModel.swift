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
    static let latitudeParam = "lat="
    static let longitudeeParam = "lon="
    static let unitsParam = "units=metric"
    static let countParam = "cnt=8"
    static let appIDParam = "appid=\(GlobalConstants.appID)"
}

// MARK: - Protocol

protocol IWeatherViewModel {
    func loadWeatherData()
    
    var currentWeather: ((CurrentWeather) -> Void)? { get set }
    var forecastDayWeather: (([ForecastDayWeather]) -> Void)? { get set }
    var forecastWeekWeather: (([ForecastWeekWeather]) -> Void)? { get set }
    var showToast: ((String) -> Void)? { get set }
}

// MARK: - Class

final class WeatherViewModel: IWeatherViewModel {
    // MARK: - Properties
        
    var currentWeather: ((CurrentWeather) -> Void)?
    var forecastDayWeather: (([ForecastDayWeather]) -> Void)?
    var forecastWeekWeather: (([ForecastWeekWeather]) -> Void)?
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
                        self?.getForecastDayWeather(coord: coordinate)
                        self?.getForecastWeekWeather(coord: coordinate)
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
    
    func getForecastDayWeather(coord: CLLocationCoordinate2D) {
        var queryParams = getQueryParams(coord: coord)
        queryParams.append("&\(Constants.countParam)")

        service.getForecastWeather(queryParams: queryParams) { [weak self] result in
            if let forecast = self?.getFormattedForecastDay(result) {
                self?.forecastDayWeather?(forecast)
            } else {
                self?.showToast?(GlobalConstants.unknownError)
            }
        }
    }
    
    func getForecastWeekWeather(coord: CLLocationCoordinate2D) {
        let queryParams = getQueryParams(coord: coord)
        
        service.getForecastWeather(queryParams: queryParams) { [weak self] result in
            if let forecast = self?.getFormattedForecastWeek(result) {
                self?.forecastWeekWeather?(forecast)
            } else {
                self?.showToast?(GlobalConstants.unknownError)
            }
        }
    }
        
    func getFormattedForecastWeek(_ forecast: ForecastResponse?) -> [ForecastWeekWeather]? {
        if let forecast {
            var array = [ForecastWeekWeather]()
            
            let formatter = DateFormatter()
            formatter.dateFormat = GlobalConstants.sortFormat
            
            for i in 0...4 {
                let date = Calendar.current.date(byAdding: .day, value: i, to: Date()) ?? Date()
                let dayForecast = forecast.list.filter { $0.dtTxt.contains(formatter.string(from: date)) }
                
                let maxTemp = dayForecast.map { $0.main.temp }.max()
                let minTemp = dayForecast.map { $0.main.temp }.min()
                
                array.append(ForecastWeekWeather(
                    tempMax: maxTemp ?? .zero,
                    tempMin: minTemp ?? .zero,
                    dateTime: Manager.shared.getFormattedDate(
                        for: date,
                        format: GlobalConstants.dayOfWeekFormat
                    ),
                    icon: dayForecast.last?.weather[.zero].icon ?? .empty
                ))
            }
            
            return array
        }
        
        return nil
    }
    
    func getFormattedForecastDay(_ forecast: ForecastResponse?) -> [ForecastDayWeather]? {
        if let forecast {
            var array = [ForecastDayWeather]()
            
            for item in forecast.list {
                array.append(ForecastDayWeather(
                    temp: item.main.temp,
                    dateTime: Manager.shared.getFormattedDate(
                        for: Date(timeIntervalSince1970: TimeInterval(item.dt)),
                        format: GlobalConstants.hourFormat
                    ),
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
                pressure: weather.main.pressure,
                hum: weather.main.humidity,
                windSpeed: weather.wind.speed,
                windDeg: weather.wind.deg,
                dateTime: Manager.shared.getFormattedDate(
                    for: Date(timeIntervalSince1970: TimeInterval(weather.dt)),
                    format: GlobalConstants.dateFormat
                ),
                description: weather.weather[.zero].description,
                icon: weather.weather[.zero].icon,
                sunrise: Manager.shared.getFormattedDate(
                    for: Date(timeIntervalSince1970: TimeInterval(weather.sys.sunrise)),
                    format: GlobalConstants.timeFormat
                ),
                sunset: Manager.shared.getFormattedDate(
                    for: Date(timeIntervalSince1970: TimeInterval(weather.sys.sunset)),
                    format: GlobalConstants.timeFormat
                )
            )
        }
        
        return nil
    }
    
    func getQueryParams(coord: CLLocationCoordinate2D) -> String {
        return "?\(Constants.unitsParam)&\(Constants.latitudeParam)\(coord.latitude)&\(Constants.longitudeeParam)\(coord.longitude)&\(Constants.appIDParam)"
    }
}
