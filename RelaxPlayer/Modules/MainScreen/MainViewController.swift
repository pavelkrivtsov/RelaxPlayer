//
//  MainViewController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 03.02.2023.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    private var noisesNames = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    private var audioSassion = AVAudioSession.sharedInstance()
    private var audioPlayers = [String: AVAudioPlayer]()
    private var selectedPlayers = [String]()
    private var selectedPlayersVolume = [String:Float]()
    
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var playbackControlsToolbar = PlaybackControlsToolbar()
    
    weak var timePickerVC: TimePickerViewController?
    
    private var timer = RelaxTimer()
    private var isTimerActive = Bool()
    private var selectedSeconds = 60
    private var remainingSeconds = Int()

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
        let isAudioPlaying = audioPlayers
            .values
            .filter { $0.isPlaying }
            .count > 0
        
        playbackControlsToolbar.playPauseButton.isEnabled = isAudioPlaying
        playbackControlsToolbar.openMixerViewButton.isEnabled = isAudioPlaying
        
        if isAudioPlaying {
            playbackControlsToolbar.updateVisualState(withPlayPauseIcon: .Pause)
        } else {
            playbackControlsToolbar.updateVisualState(withPlayPauseIcon: selectedPlayers.count > 0 ? .Play : .Stop)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        noisesNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)-> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoiseCell.reuseId,
                                                         for: indexPath) as? NoiseCell {
            let noise = noisesNames[indexPath.item]
            let player = audioPlayers[noise]
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
        let name = noisesNames[indexPath.item]
        
        if let player = audioPlayers[name] {
            if player.isPlaying {
                player.stop()
                removePlayerFromSelected(with: name)
            } else {
                if selectedPlayers.contains(name) {
                    removePlayerFromSelected(with: name)
                } else {
                    player.volume = 1
                    selectedPlayers.append(name)
                    selectedPlayersVolume[name] = 1
                    activateSelectedPlayers()
                }
            }
        } else {
            createPlayer(with: name)
            selectedPlayers.append(name)
            selectedPlayersVolume[name] = 1
            activateSelectedPlayers()
        }
        
        updateButtons()
        collectionView.reloadItems(at: [indexPath])
    }
    
    private func createPlayer(with name: String) {
        do {
            guard let audioPath = Bundle.main.path(forResource: name, ofType: "mp3") else { return }
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
            player.numberOfLoops = -1
            player.volume = 1
            player.prepareToPlay()
            audioPlayers[name] = player
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func activateSelectedPlayers() {
        do {
            try audioSassion.setActive(true)
            for (name, player) in audioPlayers {
                if selectedPlayers.contains(name) && player.isPlaying == false {
                    player.play()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func removePlayerFromSelected(with name: String) {
        if let playerIndex = selectedPlayers.firstIndex(of: name) {
            selectedPlayers.remove(at: playerIndex)
        }
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
        self.present(UINavigationController(rootViewController: timePickerVC), animated: true, completion: nil)
    }

    func playPauseButtonDidPress() {
        for playerName in selectedPlayers {
            audioPlayers[playerName]?.toggle()
        }
        updateButtons()
    }

    func openMixerDidPress() {
        let mixerVC = MixerViewController(players: selectedPlayers, playersVolume: selectedPlayersVolume)
        mixerVC.delegate = self
        self.present(UINavigationController(rootViewController: mixerVC), animated: true, completion: nil)
    }
}

// MARK: - TimePickerViewControllerDelegate
extension MainViewController: TimePickerViewControllerDelegate {

    func getSelectedSeconds(_ seconds: Int) {
        isTimerActive = true
        self.selectedSeconds = seconds
        timer.delegate = self
        timer.startTimer(with: self.selectedSeconds)
        playbackControlsToolbar.setTimeLabelText(with: self.selectedSeconds)
    }

    func cancelTimer() {
        timer.cancelTimer()
        isTimerActive = false
        playbackControlsToolbar.hideTimeLabel()
    }
}

// MARK: - MixerViewControllerDelegate
extension MainViewController: MixerViewControllerDelegate {
    
    func setPlayerVolume(name: String, volume: Float) {
        if let player = audioPlayers[name] {
            player.volume = volume
            selectedPlayersVolume[name] = volume
        }
    }

    func removePlayer(name: String) {
        if let player = audioPlayers[name] {
            player.stop()

            for player in selectedPlayers {
                if player == name, let playerIndex = selectedPlayers.firstIndex(of: player) {
                    selectedPlayers.remove(at: playerIndex)
                }
            }

            if let playerIndex =  noisesNames.firstIndex(of: name) {
                let indexPath = IndexPath(item: playerIndex, section: 0)
                collectionView.reloadItems(at: [indexPath])
            }
            updateButtons()
        }
    }

    func removeAllPlayers() {
        audioPlayers = audioPlayers.mapValues{ player in
            if player.isPlaying{
                player.stop()
            }
            return player
        }
        selectedPlayers.removeAll()
        selectedPlayersVolume.removeAll()
        collectionView.reloadData()
        updateButtons()
    }
}

// MARK: - RelaxTimerDelegate
extension MainViewController: RelaxTimerDelegate {
    
    func getRemainingSeconds(_ seconds: Int) {
        self.remainingSeconds = seconds
        playbackControlsToolbar.setTimeLabelText(with: seconds)
        let currentValue = 1 - (Double(seconds) / Double(selectedSeconds))
        timePickerVC?.startCountdownMode(seconds: seconds, value: currentValue)
    }
    
    func timerIsFinished() {
        isTimerActive = false
        audioPlayers = audioPlayers.mapValues{ player in
            if player.isPlaying{
                player.stop()
            }
            return player
        }
        updateButtons()
        timePickerVC?.stopCountdownMode()
    }
}
