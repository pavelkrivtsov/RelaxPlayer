//
//  MainViewController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 03.02.2023.
//

import UIKit

final class MainViewController: UIViewController {
    
    private let audioManager = AudioManager.shared
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var playbackControlsToolbar = PlaybackControlsToolbar()
    
    weak var timePickerVC: TimePickerViewController?
    
    private var timer = Timer()
    private var isTimerActive = Bool()
    private var selectedSeconds = 60
    private var remainingSeconds = Int()
    private var impactGenerator = UIImpactFeedbackGenerator(style: .rigid)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor")
        
        setupCollectionView()
        setupPlaybackControlsToolbar()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: createNoisesSection())
        collectionView.register(NoiseCell.self, forCellWithReuseIdentifier: NoiseCell.reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
    }
    
    private func createNoisesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
        group.interItemSpacing = .fixed(CGFloat(24))
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 0, trailing: 24)
        section.interGroupSpacing = CGFloat(24)
        return section
    }
    
    private func setupPlaybackControlsToolbar() {
        playbackControlsToolbar.delegate = self
        view.addSubview(playbackControlsToolbar)
        playbackControlsToolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playbackControlsToolbar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            playbackControlsToolbar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            playbackControlsToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
    }
    
    private func updateButtons() {
        let isAudioPlaying = audioManager.audioPlayers
            .values
            .filter { $0.isPlaying }
            .count > 0
        
        playbackControlsToolbar.playPauseButton.isEnabled = isAudioPlaying
        playbackControlsToolbar.openMixerViewButton.isEnabled = isAudioPlaying
        
        if isAudioPlaying {
            playbackControlsToolbar.updateVisualState(withPlayPauseIcon: .Pause)
        } else {
            playbackControlsToolbar.updateVisualState(withPlayPauseIcon: audioManager.selectedPlayers.count > 0 ? .Play : .Stop)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        audioManager.noisesNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)-> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoiseCell.reuseId,
                                                         for: indexPath) as? NoiseCell {
            let noise = audioManager.noisesNames[indexPath.item]
            let player = audioManager.audioPlayers[noise]
            cell.configure(imageWith: noise, isSelected: player?.isPlaying ?? false)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard collectionView.cellForItem(at: indexPath) != nil else { return }
        let name = audioManager.noisesNames[indexPath.item]
        
        if let player = audioManager.audioPlayers[name] {
            switch player.isPlaying {
            case true:
                player.stop()
                audioManager.removePlayerFromSelected(name)
            case false:
                switch audioManager.selectedPlayers.contains(name) {
                case true:
                    audioManager.removePlayerFromSelected(name)
                case false:
                    audioManager.appendToSelectedPlayers(name, 1)
                    audioManager.activateSelectedPlayers(1)
                }
            }
        } else {
            audioManager.createPlayer(name)
            audioManager.appendToSelectedPlayers(name, 1)
            audioManager.activateSelectedPlayers(1)
        }
        updateButtons()
        impactGenerator.impactOccurred()
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - PlaybackControlsToolbarDelegate
extension MainViewController: PlaybackControlsToolbarDelegate {
    
    func openTimerViewButtonDidPress() {
        let timePickerVC = TimePickerViewController(isTimerActive: isTimerActive,
                                                    selectedSeconds: selectedSeconds,
                                                    remainingSeconds: remainingSeconds)
        self.timePickerVC = timePickerVC
        self.timePickerVC?.delegate = self
        timePickerVC.navigationItem.titleView = UIImageView(image: UIImage(systemName: "timer"))
        navigationController?.pushViewController(timePickerVC, animated: true)
        impactGenerator.impactOccurred()
    }
    
    func playPauseButtonDidPress() {
        for player in audioManager.selectedPlayers {
            audioManager.audioPlayers[player]?.toggle()
        }
        updateButtons()
        impactGenerator.impactOccurred()
    }
    
    func openMixerDidPress() {
        let mixerVC = MixerViewController(players: audioManager.selectedPlayers,
                                          playersVolume: audioManager.selectedPlayersVolume)
        mixerVC.delegate = self
        mixerVC.navigationItem.titleView = UIImageView(image: UIImage(systemName: "slider.horizontal.3"))
        navigationController?.pushViewController(mixerVC, animated: true)
        impactGenerator.impactOccurred()
    }
}

// MARK: - MixerViewControllerDelegate
extension MainViewController: MixerViewControllerDelegate {
    
    func setPlayerVolume(name: String, volume: Float) {
        audioManager.setPlayerVolume(name: name, volume: volume)
    }
    
    func removePlayer(name: String) {
        if let player = audioManager.audioPlayers[name] {
            player.stop()
            audioManager.removePlayerFromSelected(name)
            if let noiseIndex = audioManager.noisesNames.firstIndex(of: name) {
                let indexPath = IndexPath(item: noiseIndex, section: 0)
                collectionView.reloadItems(at: [indexPath])
            }
            updateButtons()
        }
    }
    
    func removeAllPlayers() {
        audioManager.stopAllPlayers()
        audioManager.removeAllSelectedPlayers()
        collectionView.reloadData()
        updateButtons()
    }
}

// MARK: - TimePickerViewControllerDelegate
extension MainViewController: TimePickerViewControllerDelegate {
    
    func getSelectedSeconds(_ seconds: Int) {
        isTimerActive = true
        selectedSeconds = seconds
        timer.delegate = self
        timer.start(with: seconds)
        playbackControlsToolbar.setTimeLabelText(with: seconds)
    }
    
    func cancelTimer() {
        timer.stop()
        isTimerActive = false
        playbackControlsToolbar.hideTimeLabel()
    }
}

// MARK: - RelaxTimerDelegate
extension MainViewController: TimerDelegate {
    
    func getRemainingSeconds(_ seconds: Int) {
        remainingSeconds = seconds
        playbackControlsToolbar.setTimeLabelText(with: seconds)
        let currentValue = 1 - (Double(seconds) / Double(selectedSeconds))
        timePickerVC?.startCountdownMode(seconds: seconds, value: currentValue)
    }
    
    func timerIsFinished() {
        isTimerActive = false
        playbackControlsToolbar.hideTimeLabel()
        audioManager.stopAllPlayers()
        updateButtons()
        timePickerVC?.stopCountdownMode()
    }
}

// MARK: - MixViewControllerDelegate
extension MainViewController: MixViewControllerDelegate {
    
    func setMix(noises: [Noise]) {
        audioManager.stopAllPlayers()
        audioManager.removeAllSelectedPlayers()

        let sortedNoises = noises.sorted { noise1, noise2 in
            return noise1.createdAt < noise2.createdAt
        }

        for noise in sortedNoises {
            print("noise \(noise)")
            audioManager.createPlayer(noise.name)
            audioManager.appendToSelectedPlayers(noise.name, noise.volume)
            audioManager.activateSelectedPlayers(noise.volume)
        }
        updateButtons()
        collectionView.reloadData()
    }
}

// MARK: - UINavigationController
extension MainViewController {
    
    func embedInNavigationController() -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.navigationBar.topItem?.title = "RelaxPlayer"
        navigationController.navigationBar.topItem?.backButtonTitle = ""
        navigationController.navigationBar.tintColor = .white
        
        let button = UIBarButtonItem(image: .init(systemName: "play.square.stack"),
                                     style: .done,
                                     target: self,
                                     action: #selector(infoButtonTapped))
        button.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = button
        return navigationController
    }
    
    @objc
    private func infoButtonTapped() {
        let mixVC = MixViewController()
        mixVC.delegate = self
        mixVC.navigationItem.titleView = UIImageView(image: UIImage(systemName: "play.square.stack"))
        navigationController?.pushViewController(mixVC, animated: true)
        impactGenerator.impactOccurred()
    }
}
