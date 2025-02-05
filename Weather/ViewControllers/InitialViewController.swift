//
//  ViewController.swift
//  Weather
//
//  Created by Даниил on 5.02.25.
//

import UIKit

class InitialViewController: UIViewController {
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
}

private extension InitialViewController {
    // MARK: - Methods
    
    func configureUI() {
        view.backgroundColor = .systemBackground
    }
}

