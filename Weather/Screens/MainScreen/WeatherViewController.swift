//
//  ViewController.swift
//  Weather
//
//  Created by Даниил on 5.02.25.
//

import Toast_Swift
import Kingfisher
import SnapKit
import UIKit

// MARK: - Properties

private enum Constants {
    static let imageSize: CGFloat = 100
    static let forecastSize: CGFloat = 125
    static let buttonSize: CGFloat = 24
    
    static let compassImage = UIImage(named: "Compass")
    static let arrowImage = UIImage(named: "Arrow")
    static let listImage = UIImage(systemName: "line.horizontal.3")
    
    static let forecastDayText = "Forecast for the next 24 hours:"
    static let forecastWeekText = "Forecast for the 5 days:"
    static let temperatureText = "Temperature:"
    static let humidityText = "Humidity:"
    static let windSpeedText = "Wind speed:"
    static let pressureText = "Pressure:"
    static let sunriseText = "Sunrise:"
    static let sunsetText = "Sunset:"
    static let feelsLikeText = "Feels like:"
    static let serviceNameText = "openweathermap.org"
    static let pascalText = "hPa"
    static let msText = "m/s"
    static let percentText = "%"
}

class WeatherViewController: UIViewController {
    // MARK: - Properties
    
    private let cityInfoLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.textAlignment = .center
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let tempInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.textAlignment = .center
        return label
    }()
    
    private let tempImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    private let tempFeelsLikeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let humLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let pressureLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let windLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let windImage: UIImageView = {
        let image = UIImageView()
        image.image = Constants.arrowImage
        image.isHidden = true
        return image
    }()
    
    private let sunriseLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let sunsetLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var forecastDayCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true

        collectionView.register(ForecastDayViewCell.self, forCellWithReuseIdentifier: ForecastDayViewCell.identifier)
        collectionView.backgroundColor = .clear
        
        collectionView.contentInset = .init(
            top: .zero,
            left: GlobalConstants.horizontalSpacing,
            bottom: .zero,
            right: GlobalConstants.horizontalSpacing
        )
        
        return collectionView
    }()
    
    private lazy var forecastWeekTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = .leastNonzeroMagnitude
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ForecastWeekViewCell.self, forCellReuseIdentifier: ForecastWeekViewCell.identifier)
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private var weatherViewModel: IWeatherViewModel = WeatherViewModel()
    private var forecastDay = [ForecastDayWeather]()
    private var forecastWeek = [ForecastWeekWeather]()
    
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

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
            make.height.equalToSuperview().priority(.low)
        }
        
        let cityView = UIView()
        cityView.addSubview(cityInfoLabel)
        contentView.addSubview(cityView)

        cityView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(GlobalConstants.horizontalSpacing)
            make.right.equalToSuperview().inset(GlobalConstants.horizontalSpacing)
        }
        
        cityInfoLabel.snp.makeConstraints { make in
            make.centerX.top.bottom.equalToSuperview()
        }
        
        let citiesButton = UIButton(type: .system)
        citiesButton.setImage(Constants.listImage, for: .normal)
        citiesButton.addAction(UIAction(handler: { _ in
            self.navigationController?.pushViewController(CityViewController(), animated: true)
        }), for: .touchUpInside)
        cityView.addSubview(citiesButton)
        
        citiesButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        let tempView = WeatherInfoView()
        tempView.addSubview(tempLabel)
        tempView.addSubview(tempImage)
        tempView.addSubview(tempInfoLabel)
        tempView.addSubview(tempFeelsLikeLabel)
        contentView.addSubview(tempView)
        
        tempView.snp.makeConstraints { make in
            make.left.right.equalTo(cityView)
            make.top.equalTo(cityView.snp.bottom).offset(GlobalConstants.verticalSpacing)
        }

        tempImage.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.height.equalTo(Constants.imageSize)
            make.top.equalToSuperview().offset(-GlobalConstants.verticalSpacing)
        }
        
        tempLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-GlobalConstants.verticalSpacing)
            make.left.equalTo(tempImage.snp.right)
            make.right.equalToSuperview().inset(GlobalConstants.horizontalSpacing)
        }
        
        tempInfoLabel.snp.makeConstraints { make in
            make.left.right.equalTo(tempImage)
            make.centerY.equalTo(tempImage.snp.bottom)
            make.bottom.equalToSuperview().inset(GlobalConstants.verticalSpacing / 2)
        }
        
        tempFeelsLikeLabel.snp.makeConstraints { make in
            make.left.right.equalTo(tempLabel)
            make.centerY.equalToSuperview().offset(GlobalConstants.verticalSpacing * 2)
        }
        
        let firstView = WeatherInfoView()
        firstView.addSubview(humLabel)
        firstView.addSubview(pressureLabel)
        contentView.addSubview(firstView)
        
        firstView.snp.makeConstraints { make in
            make.left.right.equalTo(tempView)
            make.top.equalTo(tempView.snp.bottom).offset(GlobalConstants.verticalSpacing)
        }
        
        humLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(GlobalConstants.horizontalSpacing)
            make.top.equalToSuperview().offset(GlobalConstants.verticalSpacing / 2)
        }
        
        pressureLabel.snp.makeConstraints { make in
            make.left.equalTo(humLabel)
            make.top.equalTo(humLabel.snp.bottom).offset(GlobalConstants.verticalSpacing)
            make.bottom.equalToSuperview().inset(GlobalConstants.verticalSpacing / 2)
        }
        
        let secondView = WeatherInfoView()
        secondView.addSubview(sunriseLabel)
        secondView.addSubview(sunsetLabel)
        contentView.addSubview(secondView)
        
        secondView.snp.makeConstraints { make in
            make.left.right.equalTo(firstView)
            make.top.equalTo(firstView.snp.bottom).offset(GlobalConstants.verticalSpacing)
        }
        
        sunriseLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(GlobalConstants.horizontalSpacing)
            make.top.equalToSuperview().offset(GlobalConstants.verticalSpacing / 2)
        }
        
        sunsetLabel.snp.makeConstraints { make in
            make.left.equalTo(humLabel)
            make.top.equalTo(sunriseLabel.snp.bottom).offset(GlobalConstants.verticalSpacing)
            make.bottom.equalToSuperview().inset(GlobalConstants.verticalSpacing / 2)
        }
        
        let compassImage = UIImageView(image: Constants.compassImage)
        
        let windView = WeatherInfoView()
        windView.addSubview(windLabel)
        windView.addSubview(compassImage)
        compassImage.addSubview(windImage)
        contentView.addSubview(windView)
        
        windView.snp.makeConstraints { make in
            make.left.right.equalTo(secondView)
            make.top.equalTo(secondView.snp.bottom).offset(GlobalConstants.verticalSpacing)
        }
        
        windLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(GlobalConstants.horizontalSpacing)
        }
        
        compassImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(GlobalConstants.verticalSpacing / 2)
            make.left.greaterThanOrEqualTo(windLabel.snp.right).offset(GlobalConstants.horizontalSpacing)
            make.right.equalToSuperview().inset(GlobalConstants.horizontalSpacing)
            make.width.height.equalTo(Constants.imageSize / 2)
            make.bottom.equalToSuperview().inset(GlobalConstants.verticalSpacing / 2)
        }
        
        windImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview().dividedBy(1.75)
        }
        
        let forecastDayView = WeatherInfoView()
        forecastDayView.addSubview(forecastDayCollectionView)
        contentView.addSubview(forecastDayView)
        
        forecastDayView.snp.makeConstraints { make in
            make.left.right.equalTo(windView)
            make.top.equalTo(windView.snp.bottom).offset(GlobalConstants.verticalSpacing)
        }
        
        let forecastDayLabel = UILabel()
        forecastDayLabel.text = Constants.forecastDayText
        forecastDayView.addSubview(forecastDayLabel)
        
        forecastDayLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(GlobalConstants.horizontalSpacing)
            make.top.equalToSuperview().offset(GlobalConstants.verticalSpacing)
        }
        
        forecastDayCollectionView.snp.makeConstraints { make in
            make.top.equalTo(forecastDayLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(Constants.forecastSize)
        }
        
        let forecastWeekView = WeatherInfoView()
        forecastWeekView.addSubview(forecastWeekTableView)
        contentView.addSubview(forecastWeekView)
        
        forecastWeekView.snp.makeConstraints { make in
            make.left.right.equalTo(forecastDayView)
            make.top.equalTo(forecastDayView.snp.bottom).offset(GlobalConstants.verticalSpacing)
        }
        
        let forecastWeekLabel = UILabel()
        forecastWeekLabel.text = Constants.forecastWeekText
        forecastWeekView.addSubview(forecastWeekLabel)
        
        forecastWeekLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(GlobalConstants.horizontalSpacing)
            make.top.equalToSuperview().offset(GlobalConstants.verticalSpacing)
        }
        
        forecastWeekTableView.snp.makeConstraints { make in
            make.top.equalTo(forecastWeekLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(264)
        }
    
        contentView.addSubview(dateLabel)

        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(forecastWeekView.snp.bottom).offset(GlobalConstants.verticalSpacing)
            make.bottom.equalToSuperview()
        }
    }
    
    func bindViewModel() {
        weatherViewModel.currentWeather = { [weak self] weather in
            self?.cityInfoLabel.text = "\(weather.cityName), \(weather.countryCode)"
            self?.tempLabel.text = "\(Constants.temperatureText) \(weather.temp)\(GlobalConstants.degreesCelsius)"
            self?.tempImage.kf.setImage(with: URL(string: "\(GlobalConstants.imgURL)\(weather.icon)\(GlobalConstants.imgPostfix)"))
            self?.tempInfoLabel.text = weather.description
            self?.tempFeelsLikeLabel.text = "\(Constants.feelsLikeText) \(weather.tempFeelsLike)\(GlobalConstants.degreesCelsius)"
            self?.humLabel.text = "\(Constants.humidityText) \(weather.hum)\(Constants.percentText)"
            self?.pressureLabel.text = "\(Constants.pressureText) \(weather.pressure) \(Constants.pascalText)"
            self?.windLabel.text = "\(Constants.windSpeedText) \(weather.windSpeed) \(Constants.msText)"
            self?.windImage.transform = CGAffineTransform(rotationAngle: CGFloat(weather.windDeg) * .pi / 180)
            self?.windImage.isHidden = false
            self?.sunriseLabel.text = "\(Constants.sunriseText) \(weather.sunrise)"
            self?.sunsetLabel.text = "\(Constants.sunriseText) \(weather.sunset)"
            self?.dateLabel.text = "\(Constants.serviceNameText)\n\(weather.dateTime.description)"
        }
        
        weatherViewModel.forecastDayWeather = { [weak self] forecastDayArray in
            self?.forecastDay = forecastDayArray
            self?.forecastDayCollectionView.reloadData()
        }
        
        weatherViewModel.forecastWeekWeather = { [weak self] forecastWeekArray in
            self?.forecastWeek = forecastWeekArray
            self?.forecastWeekTableView.reloadData()
        }
        
        weatherViewModel.showToast = { [weak self] message in
            self?.view.makeToast(message)
        }
    }
}

extension WeatherViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - CollectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecastDay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastDayViewCell.identifier, for: indexPath) as? ForecastDayViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: forecastDay[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.forecastSize * 0.6, height: Constants.forecastSize * 0.8)
    }
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ForecastWeekViewCell.identifier, for: indexPath) as? ForecastWeekViewCell else { return UITableViewCell()}
        
        cell.configure(with: forecastWeek[indexPath.row])
        return cell
    }
}
