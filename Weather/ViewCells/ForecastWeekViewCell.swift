//
//  ForecastWeekViewCell.swift
//  Weather
//
//  Created by Даниил on 22.02.25.
//

import UIKit

// MARK: - Properties

private enum Constants {
    static let size: CGFloat = 64
    
    static let maxText = "max:"
    static let minText = "min:"
}

class ForecastWeekViewCell: UITableViewCell {
    // MARK: - Properties
    
    static var identifier: String { "\(Self.self)" }
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    private let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Livecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dateLabel.text = nil
        weatherImageView.image = nil
        tempLabel.text = nil
    }
}

extension ForecastWeekViewCell {
    // MARK: - Methods
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(dateLabel)
        contentView.addSubview(weatherImageView)
        contentView.addSubview(tempLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(GlobalConstants.verticalSpacing)
            make.bottom.equalToSuperview().inset(GlobalConstants.verticalSpacing)
            make.left.equalToSuperview().offset(GlobalConstants.horizontalSpacing)
            make.width.equalTo(Constants.size)
        }
        
        weatherImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical) // запрещаем растягиваться
        weatherImageView.snp.makeConstraints { make in
            make.left.equalTo(dateLabel.snp.right)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(Constants.size)
        }
        
        tempLabel.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(weatherImageView.snp.right)
            make.right.equalToSuperview().inset(GlobalConstants.horizontalSpacing)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with model: ForecastWeekWeather) {
        dateLabel.text = model.dateTime
        weatherImageView.kf.setImage(with: URL(string: "\(GlobalConstants.imgURL)\(model.icon)\(GlobalConstants.imgPostfix)"))
        tempLabel.text = "\(Constants.minText)\(model.tempMin)\(GlobalConstants.degreesCelsius) \(Constants.maxText)\(model.tempMax)\(GlobalConstants.degreesCelsius)"
    }
}
