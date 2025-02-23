//
//  CityViewController.swift
//  Weather
//
//  Created by Даниил on 22.02.25.
//

import SnapKit
import UIKit

// MARK: - Properties

private enum Constants {
    static let imageSize: CGFloat = 100
    static let forecastSize: CGFloat = 125
    
    static let backImage = UIImage(systemName: "chevron.left")
    
    static let title = "Cities List"
}

class CityViewController: UIViewController {
    // MARK: - Properties
    
    private lazy var citiesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = .leastNonzeroMagnitude
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(CityViewCell.self, forCellReuseIdentifier: CityViewCell.identifier)
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        return tableView
    }()

    private var cityViewModel: ICityViewModel = CityViewModel()
    private var cityArray = [CityListItem]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindViewModel()
        cityViewModel.loadCitiesData()
    }
}

private extension CityViewController {
    // MARK: - Methods
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        
        let headerView = UIView()
        view.addSubview(headerView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
        }
        
        let titleLabel = UILabel()
        titleLabel.text = Constants.title
        
        headerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let backButton = UIButton(type: .system)
        backButton.setImage(Constants.backImage, for: .normal)
        backButton.addAction(UIAction(handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        
        headerView.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(GlobalConstants.horizontalSpacing)
            make.top.bottom.equalToSuperview()
        }
        
        view.addSubview(citiesTableView)
        
        citiesTableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
    }
    
    func bindViewModel() {
        cityViewModel.citiesData = { [weak self] cities in
            self?.cityArray = cities
            self?.citiesTableView.reloadData()
        }
        
        cityViewModel.showToast = { [weak self] message in
            self?.view.makeToast(message)
        }
    }
}

extension CityViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityViewCell.identifier, for: indexPath) as? CityViewCell else { return UITableViewCell()}
        
        cell.configure(with: cityArray[indexPath.row])
        return cell
    }
}
