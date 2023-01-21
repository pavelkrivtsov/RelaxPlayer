//
//  MixerNoiseCell.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 06.02.2022.
//

import UIKit

protocol MixerNoiseCellDelegate: AnyObject {
    func changePlayerVolume(playerName: String, playerVolume: Float)
    func deletePlayerButtonPrassed(playerName: String)
}

class MixerNoiseCell: UITableViewCell {
    
    static let reuseId = "MixerNoiseCell"
    
    weak var delegate: MixerNoiseCellDelegate?
    var noiseName = String()
    var hStack = UIStackView()
    var iconImageView = UIImageView()
    var volumeSlider = UISlider()
    var deletePlayerButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemGray
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
    }
    
    private func setupVolumeSlider() {
        hStack.addArrangedSubview(volumeSlider)
        volumeSlider.minimumTrackTintColor = .white
        volumeSlider.maximumTrackTintColor = .gray
        volumeSlider.value = 1
        volumeSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    @objc
    private func sliderChanged() {
        delegate?.changePlayerVolume(playerName: noiseName, playerVolume: volumeSlider.value)
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
        deletePlayerButton.addTarget(self, action: #selector(deletePlayer), for: .touchUpInside)
    }
    
    @objc
    private func deletePlayer() {
        delegate?.deletePlayerButtonPrassed(playerName: self.noiseName)
    }
}

extension MixerNoiseCell {
    func configure(from noiseName: String) {
        self.noiseName = noiseName
        iconImageView.image = UIImage(named: noiseName)
    }
}
