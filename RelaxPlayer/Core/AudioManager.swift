//
//  AudioManager.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 06.02.2023.
//

import Foundation
import AVFoundation


final class AudioManager {
    
    static let shared = AudioManager()
    
    let noisesNames = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var audioPlayers = [String: AVAudioPlayer]()
    var selectedPlayers = [String]()
    var selectedPlayersVolume = [String : Float]()
}

extension AudioManager {
    
    func createPlayer(_ name: String) {
        do {
            guard let audioPath = Bundle.main.path(forResource: name, ofType: "mp3") else {
                print("audioPath not found")
                return
            }
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
            player.numberOfLoops = -1
            player.prepareToPlay()
            audioPlayers[name] = player
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func appendToSelectedPlayers(_ name: String, _ volume: Float) {
        selectedPlayers.append(name)
        selectedPlayersVolume[name] = volume
    }
    
    func activateSelectedPlayers() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            for name in selectedPlayers {
                if let volume = selectedPlayersVolume[name],
                   audioPlayers[name]?.isPlaying == false {
                    audioPlayers[name]?.volume = 0
                    DispatchQueue.main.async {
                        self.audioPlayers[name]?.setVolume(volume, fadeDuration: 3)
                    }
                    audioPlayers[name]?.play()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removePlayerFromSelected(_ name: String) {
        if let playerIndex = selectedPlayers.firstIndex(of: name), let player = audioPlayers[name] {
            if player.isPlaying {
                player.stop()
            }
            selectedPlayers.remove(at: playerIndex)
            selectedPlayersVolume.removeValue(forKey: name)
        }
    }
    
    func setPlayerVolume(name: String, volume: Float) {
        if let player = audioPlayers[name] {
            player.volume = volume
            selectedPlayersVolume[name] = volume
        }
    }
    
    func removeAllSelectedPlayers() {
        selectedPlayers.removeAll()
        selectedPlayersVolume.removeAll()
    }

    func stopAllPlayers() {
        audioPlayers = audioPlayers.mapValues{ player in
            if player.isPlaying{
                player.stop()
            }
            return player
        }
    }
}
