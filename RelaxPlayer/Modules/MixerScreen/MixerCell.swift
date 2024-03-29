//
//  MixerCell.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 06.02.2022.
//

import UIKit

protocol MixerCellDelegate: AnyObject {
    func setPlayerVolume(name: String, volume: Float)
    func removePlayer(name: String)
}

final class MixerCell: UITableViewCell {
    
    static let reuseId = "MixerCell"
    
    weak var delegate: MixerCellDelegate?
    private var playerName = String()
    private var hStack = UIStackView()
    private var iconImageView = UIImageView()
    private var deletePlayerButton = UIButton()
    private var volumeSlider = UISlider()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: "foregroundColor")
        setupStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStack() {
        contentView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            hStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            hStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
        ])
        
        hStack.spacing = 16
        hStack.alignment = .center
        setupIconImage()
        setupVolumeSlider()
        setupDeletePlayerButton()
    }
    
    private func setupIconImage() {
        hStack.addArrangedSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalTo: hStack.heightAnchor),
            iconImageView.widthAnchor.constraint(equalTo:  hStack.heightAnchor)
        ])
        iconImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
    }
    
    private func setupVolumeSlider() {
        hStack.addArrangedSubview(volumeSlider)
        volumeSlider.minimumTrackTintColor = .white
        volumeSlider.maximumTrackTintColor = .gray
        volumeSlider.minimumValue = 0.1
        volumeSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    @objc
    private func sliderChanged() {
        delegate?.setPlayerVolume(name: playerName, volume: volumeSlider.value)
    }
    
    private func setupDeletePlayerButton() {
        hStack.addArrangedSubview(deletePlayerButton)
        NSLayoutConstraint.activate([
            deletePlayerButton.heightAnchor.constraint(equalTo: hStack.heightAnchor),
            deletePlayerButton.widthAnchor.constraint(equalTo:  hStack.heightAnchor)
        ])
        
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "xmark")
        deletePlayerButton.configuration = configuration
        deletePlayerButton.addTarget(self, action: #selector(removePlayer), for: .touchUpInside)
    }
    
    @objc
    private func removePlayer() {
        delegate?.removePlayer(name: playerName)
    }
}

extension MixerCell {
    func configure(from noiseName: String, volume: Float) {
        playerName = noiseName
        iconImageView.image = UIImage(named: noiseName)
        volumeSlider.value = volume
    }
}
