//
//  HeaderButton.swift
//  Weather
//
//  Created by Даниил on 25.02.25.
//

import UIKit

class HeaderButton: UIButton {
    convenience init(image: UIImage?) {
        self.init(type: .system)
        
        roundConrers(cornerRadius: 8)
        backgroundColor = .separator
        setImage(image, for: .normal)
    }
}
