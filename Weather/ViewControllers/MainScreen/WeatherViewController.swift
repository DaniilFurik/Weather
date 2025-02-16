//
//  ViewController.swift
//  Weather
//
//  Created by Даниил on 5.02.25.
//

import UIKit

class WeatherViewController: UIViewController {
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
}

private extension WeatherViewController {
    // MARK: - Methods
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        
        let service = WeatherService()
        
        service.getCurrentWeather { /*[weak self]*/ result in
            if let result {
                print(result.name + result.sys.country + Date(timeIntervalSince1970: TimeInterval(result.dt)).description)
            }
        }
        
        service.getForecastWeather { /*[weak self]*/ result in
            if let result {
                print()
                print(result.cnt)
                print(result.city.country)
                print(result.list.count)
            }
        }
    }
}
