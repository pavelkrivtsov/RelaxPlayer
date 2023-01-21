//
//  MainPresenter.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 13.01.2023.
//

import Foundation

protocol MainViewOut: AnyObject {
    func openTimePickerController()
    func togglePlayback()
    func createMixerViewController()
}

protocol MainPresenterIn: AnyObject {
    func updateButtons(isAudioPlaying: Bool, isPlayerSelected: Bool)
    func removeAllPlayers()
    func removePlayerWith(playerName: String)
    func setPlayerVolume(playerName: String, playerVolume: Float)
}

class MainPresenter {
    
    weak var view: MainViewIn?
    private var collectionManager: MainPresenterOut

    init(collectionManager: MainPresenterOut) {
        self.collectionManager = collectionManager
    }
}

// MARK: - MainViewOut
extension MainPresenter: MainViewOut {
    
    func openTimePickerController() {
        let timePickerVC = TimePickerController()
        view?.present(view: timePickerVC)
    }
    
    func togglePlayback() {
        collectionManager.togglePlayback()
    }
    
    func createMixerViewController() {
        let noises = collectionManager.getSelectedPlayers()
        let noisesVolume = collectionManager.getSelectedPlayersVolume()
        let mixer = MixerASsembly.assemble(with: noises, with: noisesVolume, mainPresenter: self, mianView: view)
        
        DispatchQueue.main.async {
            self.view?.present(view: mixer)
        }
    }
}

// MARK: - MainPresenterIn
extension MainPresenter: MainPresenterIn {
    
    //    collectionManager
    func updateButtons(isAudioPlaying: Bool, isPlayerSelected: Bool) {
        DispatchQueue.main.async {
            if isAudioPlaying {
                self.view?.updatePlaybackControlsToolbar(with: .Pause)
            } else {
                self.view?.updatePlaybackControlsToolbar(with: isPlayerSelected ? .Play : .Stop)
            }
        }
    }
    
    //      mixerPresenter
    func removeAllPlayers() {
        collectionManager.removeAllPlayers()
    }
    
    func removePlayerWith(playerName: String) {
        collectionManager.removePlayerWith(playerName: playerName)
    }
    
    func setPlayerVolume(playerName: String, playerVolume: Float) {
        collectionManager.setPlayerVolume(playerName: playerName, playerVolume: playerVolume)
    }
}
