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
        
        view.addSubview(citiesCollectionView)
        
        citiesCollectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
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
        return CGSize(width: width, height: 64)
    }
}
