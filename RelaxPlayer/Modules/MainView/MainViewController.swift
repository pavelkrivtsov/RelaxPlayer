//
//  MainView.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 13.01.2023.
//

import UIKit

protocol MainViewControllerIn: AnyObject {
    func present(view: UIViewController)
    func dismiss()
    func updatePlaybackControlsToolbar(with icon: PlayPauseIcon)
    func setTimeLabelText(with seconds: Int)
    func hideTimeLabel()
}

// MARK: - MainView
class MainViewController: UIViewController {
    
    // MARK: - Properties
    private let presenter: MainViewControllerOut
    private let collectionView: UICollectionView
    private let playbackControlsToolbar = PlaybackControlsToolbar()
    
    // MARK: - init
    init(presenter: MainViewControllerOut, collectionView: UICollectionView) {
        self.presenter = presenter
        self.collectionView = collectionView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "backgroundColor")
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        
        playbackControlsToolbar.view = self
        view.addSubview(playbackControlsToolbar)
        playbackControlsToolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playbackControlsToolbar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            playbackControlsToolbar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            playbackControlsToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
    }
}

// MARK: - PlaybackControlsToolbarOut
extension MainViewController: PlaybackControlsToolbarOut {
    
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
extension MainViewController: MainViewControllerIn {

    func present(view: UIViewController) {
        self.present(view, animated: true)
    }
    
    func dismiss() {
        self.dismiss(animated: true)
    }
    
    func updatePlaybackControlsToolbar(with icon: PlayPauseIcon) {
        playbackControlsToolbar.updateVisualState(withPlayPauseIcon: icon)
    }
    
    func setTimeLabelText(with seconds: Int) {
        playbackControlsToolbar.setTimeLabelText(with: seconds)
    }

    func hideTimeLabel() {
        playbackControlsToolbar.hideTimeLabel()
    }
}
