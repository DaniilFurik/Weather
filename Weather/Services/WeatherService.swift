//
//  WeatherService.swift
//  Weather
//
//  Created by Даниил on 10.02.25.
//

import Foundation

// MARK: - Constants

private extension String {
    static let baseURL = "https://api.openweathermap.org/data/2.5"
}

private enum Components: String {
    case current = "/weather"
    case forecast = "/forecast"
}

private enum RequestType: String {
    case GET
    case POST
}

// MARK: - Protocol

protocol IWeatherService {
    func getCurrentWeather(queryParams: String, completion: @escaping (WeatherResponse?) -> Void)
    func getForecastWeather(queryParams: String, completion: @escaping (ForecastResponse?) -> Void)
}

// MARK: - Class

final class WeatherService: IWeatherService {
    // MARK: - Private Methods
    
    private func sendRequest(components: Components, queryParams: String, requestType: RequestType = .GET, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: .baseURL + components.rawValue + queryParams) else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestType.rawValue
        
        URLSession.shared.dataTask(with: urlRequest) { data, responce, error in
            DispatchQueue.main.async {
                completion(data)
            }
        }.resume()
    }
}

extension WeatherService {
    // MARK: - Methods
    
    func getCurrentWeather(queryParams: String, completion: @escaping (WeatherResponse?) -> Void) {
        sendRequest(components: .current, queryParams: queryParams) { data in
            guard let data else { return }

            let currentWeather = try? JSONDecoder().decode(WeatherResponse.self, from: data)
            completion(currentWeather)
        }
    }
    
    func getForecastWeather(queryParams: String, completion: @escaping (ForecastResponse?) -> Void) {
        sendRequest(components: .forecast, queryParams: queryParams) { data in
            guard let data else { return }

            let forecast = try? JSONDecoder().decode(ForecastResponse.self, from: data)
            completion(forecast)
        }
    }
}
