//
//  ViewController.swift
//  Weather
//
//  Created by Даниил on 5.02.25.
//

import UIKit

class WeatherViewController: UIViewController {
    // MARK: - Properties
    
    private var weatherViewModel: IWeatherViewModel = WeatherViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        weatherViewModel.loadWeatherData()
    }
}

private extension WeatherViewController {
    // MARK: - Methods
    
    func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    func bindViewModel() {
        weatherViewModel.currentWeather = { /*[weak self]*/ weather in
            print(weather.cityName)
            print(weather.countryCode)
            print(weather.dateTime)
            print(weather.description)
            print(weather.hum)
            print(weather.icon)
            print(weather.pressure)
            print(weather.sunrise)
            print(weather.sunset)
            print(weather.temp)
            print(weather.tempFeelsLike)
            print(weather.tempMax)
            print(weather.tempMin)
            print(weather.windDeg)
            print(weather.windSpeed)
            print()
        }
        
        weatherViewModel.forecastWeather = { /*[weak self]*/ forecast in
            print(forecast.cnt)
            print(forecast.city.country)
            print(forecast.list.count)
            print()
        }
    }
}
