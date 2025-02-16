//
//  WeatherService.swift
//  Weather
//
//  Created by Даниил on 10.02.25.
//

import Foundation

//apiKey = "a4c07d539a160c1d5ec3a597937067ca"

// MARK: - Constants

private extension String {
    static let baseURL = "https://api.openweathermap.org/data/2.5"
}

private enum Components: String {
    case current = "/weather"
    case forecast = "/forecast"
}

private enum QueryParams: String {
    case param = "?id=625144&units=metric&appid=a4c07d539a160c1d5ec3a597937067ca"
}

private enum RequestType: String {
    case GET
    case POST
}

// MARK: - Protocols

protocol IWeatherService {
    func getCurrentWeather(completion: @escaping (WeatherResponse?) -> Void)
    func getForecastWeather(completion: @escaping (ForecastResponse?) -> Void)
}

final class WeatherService: IWeatherService {
    // MARK: - Private Methods
    
    private func sendRequest(
        components: Components,
        params: QueryParams,
        requestType: RequestType = .GET,
        completion: @escaping (Data?) -> Void) {
            guard let url = URL(string: .baseURL + components.rawValue + params.rawValue) else { return }
            
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
    
    func getCurrentWeather(completion: @escaping (WeatherResponse?) -> Void) {
        sendRequest(components: .current, params: .param) { data in
            guard let data else { return }

            let currentWeather = try? JSONDecoder().decode(WeatherResponse.self, from: data)
            completion(currentWeather)
        }
    }
    
    func getForecastWeather(completion: @escaping (ForecastResponse?) -> Void) {
        sendRequest(components: .forecast, params: .param) { data in
            guard let data else { return }

            let forecast = try? JSONDecoder().decode(ForecastResponse.self, from: data)
            completion(forecast)
        }
    }
}
