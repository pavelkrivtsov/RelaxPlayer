//
//  MixerPresenter.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.01.2023.
//

import Foundation

protocol MixerVСOut: AnyObject {
    func cleanTableView()
}

protocol MixerPresenterIn: AnyObject {
    func tableViewCleaned()
    func removePlayer(name: String)
    func setPlayerVolume(name: String, volume: Float)
}

class MixerPresenter {
    
    weak var view: MixerVСIn?
    private let tableManager: MixerPresenterOut
    
    init(tableManager: MixerPresenterOut) {
        self.tableManager = tableManager
    }
}

// MARK: - MixerViewOut
extension MixerPresenter: MixerVСOut {
    
    func cleanTableView() {
        tableManager.cleanTableView()
    }
}

// MARK: - MixerPresenterIn
extension MixerPresenter: MixerPresenterIn {
    
    func tableViewCleaned() {
        view?.removeAllPlayers()
        DispatchQueue.main.async {
            self.view?.backToMainView()
        }
    }
    
    func removePlayer(name: String) {
        view?.removePlayer(name: name)
    }
    
    func setPlayerVolume(name: String, volume: Float) {
        view?.setPlayerVolume(name: name, volume: volume)
    }
}
