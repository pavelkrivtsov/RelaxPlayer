//
// Created by Alex on 15.2.2022.
//

import Foundation
import UIKit

protocol PlaybackControlsToolbarDelegate: AnyObject {
    func openTimerViewButtonDidPress()
    func playPauseButtonDidPress()
    func openMixerDidPress()
}

class PlaybackControlsToolbar: UIStackView {

    enum PlayPauseIcon: String {
        case Stop = "stop.fill"
        case Playing = "play.fill"
        case Pause = "pause.fill"
    }

    let openTimerViewButton = UIButton()
    let playPauseButton = UIButton()
    let openMixerViewButton = UIButton()

    weak var delegate: PlaybackControlsToolbarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemGray5
        layer.cornerRadius = 15

        spacing = 20
        alignment = .center
        distribution = .fillEqually

        var timerButtonConfiguration = UIButton.Configuration.plain()
        timerButtonConfiguration.image = UIImage(systemName: "timer")
        openTimerViewButton.configuration = timerButtonConfiguration
        openTimerViewButton.addTarget(self, action: #selector(openTimerViewButtonPressed), for: .touchUpInside)
        addArrangedSubview(openTimerViewButton)

        var playPauseButtonConfiguration = UIButton.Configuration.plain()
        playPauseButtonConfiguration.image = UIImage(systemName: "stop.fill")
        playPauseButton.configuration = playPauseButtonConfiguration
        playPauseButton.isEnabled = false
        playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed), for: .touchUpInside)
        addArrangedSubview(playPauseButton)

        var mixerButtonConfiguration = UIButton.Configuration.plain()
        mixerButtonConfiguration.image = UIImage(systemName: "slider.horizontal.3")
        openMixerViewButton.configuration = mixerButtonConfiguration
        openMixerViewButton.isEnabled = false
        openMixerViewButton.addTarget(self, action: #selector(openMixerButtonPressed), for: .touchUpInside)
        addArrangedSubview(openMixerViewButton)

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func openTimerViewButtonPressed() {
        delegate?.openTimerViewButtonDidPress()
    }

    @objc func playPauseButtonPressed() {
        delegate?.playPauseButtonDidPress()
    }

    @objc func openMixerButtonPressed() {
        delegate?.openMixerDidPress()
    }
}

extension PlaybackControlsToolbar {
    private func makeTimeText(with seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        if seconds < 3600 {
            return NSString(format: "%0.2d:%0.2d", minutes, seconds) as String
        }
        return NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
    }

    func hideTimerLabel() {
        openTimerViewButton.configuration?.subtitle = nil
        openTimerViewButton.configuration?.imagePlacement = .leading
    }

    func setTimerLabelText(with seconds: Int) {
        openTimerViewButton.configuration?.imagePlacement = .top
        openTimerViewButton.configuration?.subtitle = makeTimeText(with: seconds)
    }

    func updateVisualState(withPlayPauseIcon icon: PlayPauseIcon) {
        let image = UIImage(systemName: icon.rawValue)
        playPauseButton.configuration?.image = image

        playPauseButton.isEnabled = icon != .Stop
        openMixerViewButton.isEnabled = icon != .Stop
    }
}