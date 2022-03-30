//
//  PlaybackControlsToolbar.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 18.02.2022.
//

import UIKit

class PlaybackControlsToolbar: UIStackView {
    
    enum PlayPauseIcon: String {
        case Play = "play.fill"
        case Pause = "pause.fill"
        case Stop = "stop.fill"
    }
    
    let openTimerViewButton = UIButton()
    let playPauseButton = UIButton()
    let openMixerViewButton = UIButton()
    weak var delegate: PlaybackControlsToolbarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        backgroundColor = .systemGray
        layer.cornerRadius = 20
        clipsToBounds = true
        spacing = 20
        distribution = .fillEqually
        
        addArrangedSubview(openTimerViewButton)
        var timerButtonconfiguration = UIButton.Configuration.plain()
        timerButtonconfiguration.image = UIImage(systemName: "timer")
        timerButtonconfiguration.baseForegroundColor = .white
        openTimerViewButton.configuration = timerButtonconfiguration
        openTimerViewButton.addTarget(self, action: #selector(openTimerPickerController), for: .touchUpInside)
        
        addArrangedSubview(playPauseButton)
        var playPauseButtonconfiguration = UIButton.Configuration.plain()
        playPauseButtonconfiguration.image = UIImage(systemName: "stop.fill")
        playPauseButtonconfiguration.baseForegroundColor = .white
        playPauseButton.configuration = playPauseButtonconfiguration
        playPauseButton.isEnabled = false
        playPauseButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        
        addArrangedSubview(openMixerViewButton)
        var mixerButtonconfiguration = UIButton.Configuration.plain()
        mixerButtonconfiguration.image = UIImage(systemName: "slider.horizontal.3")
        mixerButtonconfiguration.baseForegroundColor = .white
        openMixerViewButton.configuration = mixerButtonconfiguration
        openMixerViewButton.isEnabled = false
        openMixerViewButton.addTarget(self, action: #selector(openMixerViewController), for: .touchUpInside)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openTimerPickerController() {
        delegate?.openTimerViewButtonDidPress()
    }
    
    @objc func togglePlayback() {
        delegate?.playPauseButtonDidPress()
    }
    
    @objc func openMixerViewController() {
        delegate?.openMixerDidPress()
    }
    
}

extension PlaybackControlsToolbar {
    
    private func makeTimeText(with remainingSeconds: Int) -> String {
        let hours = remainingSeconds / 3600
        let minutes = remainingSeconds / 60 % 60
        let seconds = remainingSeconds % 60
        
        if remainingSeconds < 3600 {
            return NSString(format: "%0.2d:%0.2d", minutes, seconds) as String
        }
        return NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
    }
    
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

protocol PlaybackControlsToolbarDelegate: AnyObject {
    func openTimerViewButtonDidPress()
    func playPauseButtonDidPress()
    func openMixerDidPress()
}
