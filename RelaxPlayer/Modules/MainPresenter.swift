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
    func openmixerViewController()
}

protocol MainPresenterIn: AnyObject {
    func updateButtons(isAudioPlaying: Bool, isPlayerSelected: Bool)
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
        //        timePickerVC.delegate = self
        //        self.timePickerVC = timePickerVC
        //        timePickerVC.isTimerActive = isTimerActive
        
        //        if timePickerVC.isTimerActive {
        //            timePickerVC.timePickerView.setTimeLabelText(with: seconds)
        //            timePickerVC.selectedSeconds = selectedSeconds
        //            timePickerVC.remainingSeconds = seconds
        //        }
        view?.present(view: timePickerVC)
    }
    
    func togglePlayback() {
        collectionManager.togglePlayback()
    }
    
    func openmixerViewController() {
        let mixerVC = MixerViewController()
        //        mixerVC.delegate = self
        //        mixerVC.noises = self.selectedPlayers
        //        mixerVC.selectedPlayersVolume = selectedPlayersVolume
        view?.present(view: mixerVC)
    }
}

// MARK: - MainPresenterIn
extension MainPresenter: MainPresenterIn {
    
    func updateButtons(isAudioPlaying: Bool, isPlayerSelected: Bool) {
        view?.updateButtons(isAudioPlaying: isAudioPlaying)
        
        if isAudioPlaying {
            view?.updatePlaybackControlsToolbar(with: .Pause)
        } else {
            view?.updatePlaybackControlsToolbar(with: isPlayerSelected ? .Play : .Stop)
        }
    }
}

// MARK: - TimePickerControllerDelegate
extension MainPresenter: TimePickerControllerDelegate {
    
    func get(selectedSeconds: Int) {
        
    }
    
    func deleteTimer() {
        
    }
}
