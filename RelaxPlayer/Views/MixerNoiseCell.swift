//
//  MixerNoiseCell.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 06.02.2022.
//

import UIKit

class MixerNoiseCell: UITableViewCell {
    
    //  MARK: - declaring variables
    static let reuseId = "MixerNoiseCell"
    var mixerStack = UIStackView()
    var iconImageView = UIImageView()
    var volumeSlider = UISlider()
    var noiseName = String()
    var volumeOnCompletion: ((String, Float) -> ())?
    
    //  MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStack()
    }
    
    //  MARK: - setup stack
    func setupStack() {
        contentView.addSubview(mixerStack)
        mixerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mixerStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            mixerStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            mixerStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            mixerStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
        ])
        mixerStack.spacing = 15
        setupIconImage()
        setupVolumeSlider()
    }
    
    //  MARK: - setup icon image view
    func setupIconImage() {
        mixerStack.addArrangedSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalTo: mixerStack.heightAnchor),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor)
        ])
    }
    
    //  MARK: - setup slider
    func setupVolumeSlider() {
        mixerStack.addArrangedSubview(volumeSlider)
        volumeSlider.value = 1
        volumeSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    @objc func sliderChanged() {
        volumeOnCompletion?(self.noiseName, volumeSlider.value)
    }
    
    //  MARK: - required init?(coder: NSCoder)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
