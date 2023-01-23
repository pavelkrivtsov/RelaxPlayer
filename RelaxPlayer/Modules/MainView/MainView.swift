//
//  MainView.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 13.01.2023.
//

import UIKit

protocol MainViewIn: AnyObject {
    func present(view: UIViewController)
    func updatePlaybackControlsToolbar(with icon: PlayPauseIcon)
    func dismiss()
    func removeAllPlayers()
    func removePlayerWith(playerName: String)
    func setPlayerVolume(playerName: String, playerVolume: Float)
}

// MARK: - MainView
class MainView: UIViewController {
    
    // MARK: - Properties
    private let presenter: MainViewOut
    private let collectionView: UICollectionView
    private var playbackControlsToolbar = PlaybackControlsToolbar()
    
    // MARK: - init
    init(presenter: MainViewOut, collectionView: UICollectionView) {
        self.presenter = presenter
        self.collectionView = collectionView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        
        playbackControlsToolbar.delegate = self
        view.addSubview(playbackControlsToolbar)
        playbackControlsToolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playbackControlsToolbar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            playbackControlsToolbar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            playbackControlsToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
    }
}

// MARK: - PlaybackControlsToolbarDelegate
extension MainView: PlaybackControlsToolbarDelegate {
    
    func openTimerViewButtonDidPress() {
        presenter.createTimePickerController()
    }
    
    func playPauseButtonDidPress() {
        presenter.togglePlayback()
    }
    
    func openMixerDidPress() {
        presenter.createMixerViewController()
    }
}

// MARK: - MainViewIn
extension MainView: MainViewIn {
    
    //    MainPresenter
    func present(view: UIViewController) {
        self.present(view, animated: true)
    }
    
    func updatePlaybackControlsToolbar(with icon: PlayPauseIcon) {
        playbackControlsToolbar.updateVisualState(withPlayPauseIcon: icon)
    }
    
    //    MixerView
    func dismiss() {
        self.dismiss(animated: true)
    }
    
    func removeAllPlayers() {
        presenter.removeAllPlayers()
    }
    
    func removePlayerWith(playerName: String) {
        presenter.removePlayerWith(playerName: playerName)
    }
    
    func setPlayerVolume(playerName: String, playerVolume: Float) {
        presenter.setPlayerVolume(playerName: playerName, playerVolume: playerVolume)
    }
}
