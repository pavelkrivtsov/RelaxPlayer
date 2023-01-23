//
//  MixerPresenter.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.01.2023.
//

import Foundation

protocol MixerViewOut: AnyObject {
    func cleanTableView()
}

protocol MixerPresenterIn: AnyObject {
    func tableViewCleaned()
    func removePlayerWith(playerName: String)
    func setPlayerVolume(playerName: String, playerVolume: Float)
}

class MixerPresenter {
    
    weak var view: MixerViewIn?
    private let tableManager: MixerPresenterOut
    
    init(tableManager: MixerPresenterOut) {
        self.tableManager = tableManager
    }
}

// MARK: - MixerViewOut
extension MixerPresenter: MixerViewOut {
    
    func cleanTableView() {
        tableManager.cleanTableView()
    }
}

// MARK: - MixerPresenterIn
extension MixerPresenter: MixerPresenterIn {
    
    func tableViewCleaned() {
        self.view?.removeAllPlayers()
        DispatchQueue.main.async {
            self.view?.backToMainView()
        }
    }
    
    func removePlayerWith(playerName: String) {
        view?.removePlayerWith(playerName: playerName)
    }
    
    func setPlayerVolume(playerName: String, playerVolume: Float) {
        view?.setPlayerVolume(playerName: playerName, playerVolume: playerVolume)
    }
}
