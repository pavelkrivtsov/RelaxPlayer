//
//  MainNoiseCell.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 13.01.2023.
//

import UIKit

class MainNoiseCell: UICollectionViewCell {
    
    static let reuseId = "MainNoiseCell"
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 15
        clipsToBounds = true
        contentView.addSubview(iconImageView)
        iconImageView.frame = self.contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageWith icon: String, isSelected: Bool) {
        backgroundColor = isSelected ? .systemGray : .clear
        iconImageView.image = UIImage(named: icon)
    }
}
