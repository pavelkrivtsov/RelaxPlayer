//
//  MainVCNoiseCell.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 27.12.2021.
//

import UIKit

class MainVCNoiseCell: UICollectionViewCell {
    
    static let reuseId = "MainNoiseCell"
    let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 15
        clipsToBounds = true
        setupImageView()
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
        backgroundColor = isSelected ? .systemGray : .clear
        iconImageView.image = UIImage(named: icon)
    }
    
}
