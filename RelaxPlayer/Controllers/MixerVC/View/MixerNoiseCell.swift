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
    
    var noiseName = String()
    var mixerStack = UIStackView()
    var iconImageView = UIImageView()
    var volumeSlider = UISlider()
    var deletePlayerButton = UIButton()
    weak var delegate: MixerNoiseCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemGray
        setupStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupStack() {
        contentView.addSubview(mixerStack)
        mixerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mixerStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            mixerStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            mixerStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            mixerStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
        ])
        mixerStack.spacing = 15
        mixerStack.alignment = .center
        setupIconImage()
        setupVolumeSlider()
        setupDeletePlayerButton()
    }
    
    fileprivate func setupIconImage() {
        mixerStack.addArrangedSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalTo: mixerStack.heightAnchor),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor)
        ])
    }
    
    fileprivate func setupVolumeSlider() {
        mixerStack.addArrangedSubview(volumeSlider)
        volumeSlider.minimumTrackTintColor = .white
        volumeSlider.maximumTrackTintColor = .gray
        volumeSlider.value = 1
        volumeSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    @objc fileprivate func sliderChanged() {
        delegate?.changePlayerVolume(playerName: noiseName, playerVolume: volumeSlider.value)
    }
    
    fileprivate func setupDeletePlayerButton() {
        mixerStack.addArrangedSubview(deletePlayerButton)
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        configuration.image = UIImage(systemName: "xmark")
        configuration.baseForegroundColor = .white
        deletePlayerButton.configuration = configuration
        deletePlayerButton.addTarget(self, action: #selector(deletePlayer), for: .touchUpInside)
    }
    
    @objc fileprivate func deletePlayer() {
        delegate?.deletePlayerButtonPrassed(playerName: self.noiseName)
    }
}
