//
//  PlaybackControlsToolbar.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 18.02.2022.
//

import UIKit

protocol PlaybackControlsToolbarDelegate: AnyObject {
    func openTimerViewButtonDidPress()
    func playPauseButtonDidPress()
    func openMixerDidPress()
}

class PlaybackControlsToolbar: UIStackView {
    
    enum PlayPauseIcon: String {
        case Play = "play.fill"
        case Pause = "pause.fill"
        case Stop = "stop.fill"
    }
        
    weak var delegate: PlaybackControlsToolbarDelegate?
    private let openTimerViewButton = UIButton()
    let playPauseButton = UIButton()
    let openMixerViewButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        backgroundColor = UIColor(named: "foregroundColor")
        layer.cornerRadius = 24
        clipsToBounds = true
        spacing = 24
        distribution = .fillEqually
        
        addArrangedSubview(openTimerViewButton)
        var timerButtonConfiguration = UIButton.Configuration.plain()
        timerButtonConfiguration.image = UIImage(systemName: "timer")
        timerButtonConfiguration.baseForegroundColor = .white
        openTimerViewButton.configuration = timerButtonConfiguration
        openTimerViewButton.addTarget(self, action: #selector(openTimerPickerController), for: .touchUpInside)
        
        addArrangedSubview(playPauseButton)
        var playPauseButtonConfiguration = UIButton.Configuration.plain()
        playPauseButtonConfiguration.image = UIImage(systemName: "stop.fill")
        playPauseButtonConfiguration.baseForegroundColor = .white
        playPauseButton.configuration = playPauseButtonConfiguration
        playPauseButton.isEnabled = false
        playPauseButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        
        addArrangedSubview(openMixerViewButton)
        var mixerButtonConfiguration = UIButton.Configuration.plain()
        mixerButtonConfiguration.image = UIImage(systemName: "slider.horizontal.3")
        mixerButtonConfiguration.baseForegroundColor = .white
        openMixerViewButton.configuration = mixerButtonConfiguration
        openMixerViewButton.isEnabled = false
        openMixerViewButton.addTarget(self, action: #selector(openMixerViewController), for: .touchUpInside)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func openTimerPickerController() {
        delegate?.openTimerViewButtonDidPress()
    }
    
    @objc
    private func togglePlayback() {
        delegate?.playPauseButtonDidPress()
    }
    
    @objc
    private func openMixerViewController() {
        delegate?.openMixerDidPress()
    }
    
    private func makeTimeText(with remainingSeconds: Int) -> String {
        let hours = remainingSeconds / 3600
        let minutes = remainingSeconds / 60 % 60
        let seconds = remainingSeconds % 60
        
        if remainingSeconds < 3600 {
            return NSString(format: "%0.2d:%0.2d", minutes, seconds) as String
        }
        return NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
    }
}

extension PlaybackControlsToolbar {
        
    func hideTimeLabel() {
        openTimerViewButton.configuration?.subtitle = nil
        openTimerViewButton.configuration?.imagePlacement = .leading
    }
    
    func setTimeLabelText(with seconds: Int) {
        openTimerViewButton.configuration?.subtitle = makeTimeText(with: seconds)
        openTimerViewButton.configuration?.imagePlacement = .top
    }
    
    func updateVisualState(withPlayPauseIcon icon: PlayPauseIcon) {
        let image = UIImage(systemName: icon.rawValue)
        playPauseButton.configuration?.image = image
        
        playPauseButton.isEnabled = icon != .Stop
        openMixerViewButton.isEnabled = icon != .Stop
    }
}
