//
//  UserDefaults+Extensions.swift
//  Racing2D
//
//  Created by Даниил on 13.12.24.
//

import UIKit

private enum Constants {
    static let settingsText = "Settings"
    static let cancelText = "Cancel"
}

extension UIViewController {
    func showSettingsAlert() {
        let alertController = UIAlertController(title: GlobalConstants.noLocationAccess, message: .empty, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: Constants.settingsText, style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { _ in })
                }
            }
        }
            
        alertController.addAction(UIAlertAction(title: Constants.cancelText, style: .cancel))
        alertController.addAction(settingsAction)
        present(alertController, animated: true)
    }
}
