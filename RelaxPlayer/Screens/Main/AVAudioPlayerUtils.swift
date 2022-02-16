//
// Created by Alex on 15.2.2022.
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