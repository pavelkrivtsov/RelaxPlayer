//
//  MainPresenter.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 13.01.2023.
//

import Foundation

protocol MainViewOut: AnyObject {
    func createTimePickerController()
    func togglePlayback()
    func createMixerViewController()
    func removeAllPlayers()
    func removePlayerWith(playerName: String)
    func setPlayerVolume(playerName: String, playerVolume: Float)
}

protocol MainPresenterIn: AnyObject {
    func updateButtons(isAudioPlaying: Bool, isPlayerSelected: Bool)
}

// MARK: - MainPresenter
class MainPresenter {
    
    weak var view: MainViewIn?
    private var collectionManager: MainPresenterOut

    init(collectionManager: MainPresenterOut) {
        self.collectionManager = collectionManager
    }
}

// MARK: - MainViewOut
extension MainPresenter: MainViewOut {
    
//    mian view
    func createTimePickerController() {
        let timePickerVC = TimePickerController()
    
        DispatchQueue.main.async {
            self.view?.present(view: timePickerVC)
        }
    }
    
    func togglePlayback() {
        collectionManager.togglePlayback()
    }
    
    func createMixerViewController() {
        let noises = collectionManager.getSelectedPlayers()
        let noisesVolume = collectionManager.getSelectedPlayersVolume()
        let mixer = MixerAssembly.assemble(with: noises,
                                           with: noisesVolume,
                                           mianView: view)
        DispatchQueue.main.async {
            self.view?.present(view: mixer)
        }
    }

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

// MARK: - MainPresenterIn
extension MainPresenter: MainPresenterIn {
    
    func updateButtons(isAudioPlaying: Bool, isPlayerSelected: Bool) {
        DispatchQueue.main.async {
            if isAudioPlaying {
                self.view?.updatePlaybackControlsToolbar(with: .Pause)
            } else {
                self.view?.updatePlaybackControlsToolbar(with: isPlayerSelected ? .Play : .Stop)
            }
        }
    }
}
