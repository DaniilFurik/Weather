//
//  WeatherInfoView.swift
//  Weather
//
//  Created by Даниил on 19.02.25.
//

import UIKit

class WeatherInfoView: UIView {
    convenience init() {
        self.init(frame: .zero)
        
        roundConrers()
        backgroundColor = .separator
    }
}
