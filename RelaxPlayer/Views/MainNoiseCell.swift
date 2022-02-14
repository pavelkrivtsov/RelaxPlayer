//
//  NoiseCell.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 27.12.2021.
//

import UIKit

class MainNoiseCell: UICollectionViewCell {
    
    //  MARK: - declaring variables
    static let reuseId = "MainNoiseCell"
    let iconImageView = UIImageView()
    
    //  MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 15
        setupImageView()
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - setup image view
    private func setupImageView() {
        contentView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            iconImageView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor)
        ])
    }
    
    func configure(imageWith icon: String, isSelected: Bool) {
        contentView.backgroundColor = isSelected ? .systemGray4 : .systemGray2
        iconImageView.image = UIImage(named: icon)
    }
    
}
