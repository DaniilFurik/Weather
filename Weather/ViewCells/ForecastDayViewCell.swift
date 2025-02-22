//
//  ForecastViewCell.swift
//  Weather
//
//  Created by Даниил on 19.02.25.
//

import Kingfisher
import UIKit

class ForecastDayViewCell: UICollectionViewCell {
    // MARK: - Properties
    
    static var identifier: String { "\(Self.self)" }

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
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
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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

extension ForecastDayViewCell {
    // MARK: - Methods
    
    private func configureUI() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(weatherImageView)
        contentView.addSubview(tempLabel)

        dateLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        weatherImageView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.centerY)
            make.centerX.equalToSuperview()
        }
        
        weatherImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        tempLabel.snp.makeConstraints { make in
            make.centerY.equalTo(weatherImageView.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
    }
    
    func configure(with model: ForecastDayWeather) {
        dateLabel.text = model.dateTime
        weatherImageView.kf.setImage(with: URL(string: "\(GlobalConstants.imgURL)\(model.icon)\(GlobalConstants.imgPostfix)"))
        tempLabel.text = "\(model.temp)\(GlobalConstants.degreesCelsius)"
    }
}
