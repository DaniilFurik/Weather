//
//  UIView+Extensions.swift
//  Weather
//
//  Created by Даниил on 19.02.25.
//

import UIKit

//MARK: - Constants

private enum Constantss {
    static let cornerRadius: CGFloat = 15
    static let opacity: Float = 0.5
    static let shadowRadius: CGFloat = 10
    static let offset: CGFloat = 10
}

extension UIView {
    //MARK: - Methods
    
    func roundConrers(cornerRadius: CGFloat = Constantss.cornerRadius) {
        layer.cornerRadius = cornerRadius
    }
    
    func dropShadow() {
        layer.masksToBounds = false // тень за границей экрана
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constantss.opacity
        layer.shadowOffset = CGSize(width: Constantss.offset, height: Constantss.offset)
        layer.shadowRadius = Constantss.shadowRadius
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true // делает тень более грубой (более натуральной)
    }
}
