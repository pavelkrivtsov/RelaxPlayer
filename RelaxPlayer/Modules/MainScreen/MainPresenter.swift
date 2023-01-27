//
//  MainPresenter.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 13.01.2023.
//

import Foundation

protocol MainViewControllerOut: AnyObject {
    func createTimePickerController()
    func togglePlayback()
    func createMixerViewController()
}

protocol CollectionManagerOut: AnyObject {
    func updateButtons(isAudioPlaying: Bool, isPlayerSelected: Bool)
}

protocol MixerViewControllerOut: AnyObject {
    func removeAllPlayers()
    func removePlayer(name: String)
    func setPlayerVolume(name: String, volume: Float)
}

protocol TimePickerViewControllerOut: AnyObject {
    func getFromTimePicker(selectedSeconds: Int)
    func togglePlayPause()
}

protocol TimerManagerOut: AnyObject {
    func getRemainingSeconds(_ seconds: Int)
    func timerIsFinished()
}


// MARK: - MainPresenter
class MainPresenter {
    
    weak var view: MainViewControllerIn?
    private let collectionManager: CollectionManagerIn
    private let timerManager: TimerManagerIn
    
    private lazy var timePickerVC = TimePickerViewController()
    
    private var isTimerActive = false
    private var selectedSeconds = 60
    
    init(collectionManager: CollectionManagerIn,
         timerManager: TimerManagerIn) {
        self.collectionManager = collectionManager
        self.timerManager = timerManager
    }
}

// MARK: - MainViewControllerOut
extension MainPresenter: MainViewControllerOut {

    func createTimePickerController() {
        timePickerVC.presenter = self
        DispatchQueue.main.async {
            self.view?.present(view: self.timePickerVC)
        }
    }
    
    func togglePlayback() {
        collectionManager.togglePlayback()
    }
    
    func createMixerViewController() {
        let players = collectionManager.getSelectedPlayers()
        let playersVolume = collectionManager.getSelectedPlayersVolume()
        
        DispatchQueue.main.async {
            let mixerView = MixerAssembly.assemble(players: players,
                                                   playersVolume: playersVolume,
                                                   presenter: self)
            self.view?.present(view: mixerView)
        }
    }
}

// MARK: - CollectionManagerOut
extension MainPresenter: CollectionManagerOut {
    
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

// MARK: - MixerViewControllerOut
extension MainPresenter: MixerViewControllerOut {
    
    func removeAllPlayers() {
        collectionManager.removeAllPlayers()
        view?.dismiss()
    }
    
    func removePlayer(name: String) {
        collectionManager.removePlayer(name: name)
    }
    
    func setPlayerVolume(name: String, volume: Float) {
        collectionManager.setPlayerVolume(name: name, volume: volume)
    }
}

// MARK: - TimePickerViewControllerOut
extension MainPresenter: TimePickerViewControllerOut {
    
    func getFromTimePicker(selectedSeconds: Int) {
        self.selectedSeconds = selectedSeconds
    }
    
    func togglePlayPause() {
        isTimerActive.toggle()
    
        if isTimerActive {
            timerManager.startTimer(with: selectedSeconds)
            timePickerVC.prepareCountdownMode(with: selectedSeconds)
            view?.setTimeLabelText(with: selectedSeconds)
        } else {
            timerManager.cancelTimer()
            timePickerVC.stopCountdownMode()
            view?.hideTimeLabel()
        }
    }
}

// MARK: - TimerManagerOut
extension MainPresenter: TimerManagerOut {
    
    func getRemainingSeconds(_ seconds: Int) {
        view?.setTimeLabelText(with: seconds)
        timePickerVC.startCountdownMode(with: seconds)
    }
    
    func timerIsFinished() {
        isTimerActive.toggle()
        timePickerVC.stopCountdownMode()
        removeAllPlayers()
    }
}
