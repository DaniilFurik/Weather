//
//  CityViewCell.swift
//  Weather
//
//  Created by Даниил on 22.02.25.
//

import UIKit

class CityViewCell: UICollectionViewCell {
    // MARK: - Properties
    
    static var identifier: String { "\(Self.self)" }
    
    private let cityNameLabel: UILabel = {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cityNameLabel.text = nil
        weatherImageView.image = nil
        tempLabel.text = nil
    }
}

extension CityViewCell {
    // MARK: - Methods
    
    private func configureUI() {
        contentView.backgroundColor = .separator
        contentView.roundConrers()
        
        contentView.addSubview(cityNameLabel)
        contentView.addSubview(weatherImageView)
        contentView.addSubview(tempLabel)
    
        cityNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(GlobalConstants.verticalSpacing)
            make.bottom.equalToSuperview().inset(GlobalConstants.verticalSpacing)
            make.left.equalToSuperview().offset(GlobalConstants.horizontalSpacing)
        }
        
        weatherImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical) // запрещаем растягиваться
        weatherImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(GlobalConstants.horizontalSpacing)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(GlobalConstants.citySize)
        }
        
        tempLabel.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(cityNameLabel.snp.right)
            make.right.equalTo(weatherImageView.snp.left).offset(-GlobalConstants.horizontalSpacing)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with model: CityListItem) {
        cityNameLabel.text = "\(model.name), \(model.country)"
        tempLabel.text = "\(model.temp)\(GlobalConstants.degreesCelsius)"
        weatherImageView.kf.setImage(with: URL(string: "\(GlobalConstants.imgURL)\(model.icon)\(GlobalConstants.imgPostfix)"))
    }
}
