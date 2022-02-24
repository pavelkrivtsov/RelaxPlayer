//
//  PlaybackControlsToolbarDelegate.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 18.02.2022.
//

import Foundation

protocol PlaybackControlsToolbarDelegate: AnyObject {
    func openTimerViewButtonDidPress()
    func playPauseButtonDidPress()
    func openMixerDidPress()
}
