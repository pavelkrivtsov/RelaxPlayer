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
    
    func createPlayer(with name: String) {
        do {
            guard let audioPath = Bundle.main.path(forResource: name, ofType: "mp3") else {
                print("audioPath not found")
                return
            }
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
            player.numberOfLoops = -1
            player.volume = 1
            player.prepareToPlay()
            audioPlayers[name] = player
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func appendPlayer(with name: String) {
        selectedPlayers.append(name)
        selectedPlayersVolume[name] = 1
    }
    
    func activateSelectedPlayers() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            for (name, player) in audioPlayers {
                if selectedPlayers.contains(name) && player.isPlaying == false {
                    player.play()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removePlayerFromSelected(with name: String) {
        if let playerIndex = selectedPlayers.firstIndex(of: name) {
            selectedPlayers.remove(at: playerIndex)
        }
    }
    
    func setPlayerVolume(name: String, volume: Float) {
        if let player = audioPlayers[name] {
            player.volume = volume
            selectedPlayersVolume[name] = volume
        }
    }
    
    func removePlayer(name: String) {
        for player in selectedPlayers {
            if player == name, let playerIndex = selectedPlayers.firstIndex(of: player) {
                selectedPlayers.remove(at: playerIndex)
            }
        }
    }
    
    func removeAllPlayers() {
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
