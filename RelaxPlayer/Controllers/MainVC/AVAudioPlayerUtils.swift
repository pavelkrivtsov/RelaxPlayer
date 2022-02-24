//
//  AVAudioPlayerUtils.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 18.02.2022.
//

import Foundation
import AVFoundation

extension AVAudioPlayer {
    func toggle() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
}
