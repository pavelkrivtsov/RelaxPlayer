//
//  NoiseCell.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 27.12.2021.
//

import UIKit

class MainNoiseCell: UICollectionViewCell {
    
    static let reuseId = "MainNoiseCell"
    let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        contentView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(imageWith icon: String, isSelected: Bool) {
        iconImageView.backgroundColor = isSelected ? .systemGray4 : .systemGray2
        iconImageView.image = UIImage(named: icon)
    }
    
}
