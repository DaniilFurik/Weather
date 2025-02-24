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
    
    static let title = "Weather in other cities"
    static let cityPlaceholder = "Enter city name"
    
    static let cellIdentifier: String = "CityNameCell"
}

class CityViewController: UIViewController {
    // MARK: - Properties
    
    private lazy var citiesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true

        collectionView.register(CityViewCell.self, forCellWithReuseIdentifier: CityViewCell.identifier)
        collectionView.backgroundColor = .clear
        
        collectionView.contentInset = .init(
            top: GlobalConstants.verticalSpacing,
            left: GlobalConstants.horizontalSpacing,
            bottom: .zero,
            right: GlobalConstants.horizontalSpacing
        )
        
        return collectionView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = Constants.cityPlaceholder
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        return tableView
    }()

    private var cityViewModel: ICityViewModel = CityViewModel()
    private var cityArray = [CityListItem]()
    private var searchResults = [CityInfo]()
    
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
            make.height.equalTo(GlobalConstants.headerSize)
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
        
        let containerView = UIView()
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
        
        containerView.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
        
        containerView.addSubview(citiesCollectionView)
        
        citiesCollectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
        }
        
        containerView.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
            make.height.equalTo(Int.zero)
        }
    }
    
    func bindViewModel() {
        cityViewModel.citiesData = { [weak self] cities in
            self?.cityArray = cities
            self?.citiesCollectionView.reloadData()
        }
        
        cityViewModel.showToast = { [weak self] message in
            self?.view.makeToast(message)
        }
    }
}

extension CityViewController: UISearchBarDelegate {
    // MARK: - SearchBar Methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResults = []
            
            tableView.snp.updateConstraints { make in
                make.height.equalTo(Int.zero)
            }
        } else {
            cityViewModel.searchCities(name: searchText, completion: { [weak self] cities in
                self?.searchResults = cities
                self?.tableView.reloadData()
            })
            
            tableView.snp.updateConstraints { make in
                make.height.equalTo(view.frame.height - searchBar.convert(CGPoint(x: searchBar.frame.maxX, y: searchBar.frame.maxY), to: nil).y)
            }
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Скрываем клавиатуру
        searchBar.resignFirstResponder()
    }
}

extension CityViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let city = searchResults[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        cell.textLabel?.text = "\(city.name), \(city.country)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        searchBar.text = .empty
        
        cityViewModel.saveCity(city: searchResults[indexPath.row])
        
        tableView.snp.updateConstraints { make in
            make.height.equalTo(Int.zero)
        }
    }
}

extension CityViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - CollectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cityArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityViewCell.identifier, for: indexPath) as? CityViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: cityArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        return CGSize(width: width, height: GlobalConstants.citySize)
    }
}
