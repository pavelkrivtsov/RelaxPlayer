//
//  MainViewController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 27.12.2021.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    //  MARK: - declaring variables
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    var noises = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var audioSassion = AVAudioSession.sharedInstance()
    var audioPlayers = [String: AVAudioPlayer]()
    var selectedPlayers = [String]()
    var selectedPlayersVolume = [String:Float]()
    var playbackControlsToolbar = PlaybackControlsToolbar()
    var backgroundImageView = UIImageView(image: UIImage(named: "background"))
    
    var timer = RelaxTimer()
    var isTimerActive = false
    var seconds = Int()
    var selectedSeconds = Int()
    weak var timePickerVC: TimePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImageView()
        setupCollectionView()
        setupPlaybackControlsToolbar()
    }
    
    func setupBackgroundImageView() {
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: createNoisesSection())
        collectionView.register(MainVCNoiseCell.self, forCellWithReuseIdentifier: MainVCNoiseCell.reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
    }
    
    func createNoisesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
        group.interItemSpacing = .fixed(CGFloat(20))
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = CGFloat(20)
        return section
    }
    
    func setupPlaybackControlsToolbar() {
        playbackControlsToolbar.delegate = self
        collectionView.addSubview(playbackControlsToolbar)
        NSLayoutConstraint.activate([
            playbackControlsToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            playbackControlsToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            playbackControlsToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
    }
    
    func openTimePickerController() {
        let timePickerVC = TimePickerController()
        timePickerVC.delegate = self
        self.timePickerVC = timePickerVC
        timePickerVC.isTimerActive = isTimerActive
        
        if timePickerVC.isTimerActive {
            timePickerVC.timePickerView.setTimeLabelText(with: seconds)
            timePickerVC.selectedSeconds = selectedSeconds
            timePickerVC.remainingSeconds = seconds
        }
        self.present(UINavigationController(rootViewController: timePickerVC), animated: true, completion: nil)
    }
    
    func openMixerViewController() {
        let mixerVC = MixerViewController()
        mixerVC.delegate = self
        mixerVC.noises = self.selectedPlayers
        mixerVC.selectedPlayersVolume = selectedPlayersVolume
        self.present(UINavigationController(rootViewController: mixerVC), animated: true, completion: nil)
    }
    
    func updateButtons() {
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
    
    func togglePlayback() {
        for playerName in selectedPlayers {
            audioPlayers[playerName]?.toggle()
        }
        updateButtons()
    }
    
}


extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        noises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)-> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainVCNoiseCell.reuseId,
                                                         for: indexPath) as? MainVCNoiseCell {
            let noise = noises[indexPath.item]
            let player = audioPlayers[noise]
            cell.configure(imageWith: noise, isSelected: player?.isPlaying ?? false)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard collectionView.cellForItem(at: indexPath) != nil else { return }
        let noise = noises[indexPath.item]
        
        if let audioPlayer = audioPlayers[noise] {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
                for player in selectedPlayers {
                    if player == noise, let playerIndex = selectedPlayers.firstIndex(of: player) {
                        selectedPlayers.remove(at: playerIndex)
                    }
                }
            } else {
                if selectedPlayers.contains(noise) {
                    for player in selectedPlayers {
                        if player == noise, let playerIndex = selectedPlayers.firstIndex(of: player) {
                            selectedPlayers.remove(at: playerIndex)
                        }
                    }
                } else {
                    do {
                        try audioSassion.setActive(true)
                        audioPlayer.play()
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    selectedPlayers.append(noise)
                    for (noise, player) in audioPlayers {
                        if selectedPlayers.contains(noise) && player.isPlaying == false {
                            player.play()
                        }
                    }
                }
            }
            
        } else {
            do {
                guard let audioPath = Bundle.main.path(forResource: noise, ofType: "mp3") else { return }
                let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
                try audioSassion.setActive(true)
                audioPlayer.volume = 1
                audioPlayer.numberOfLoops = -1
                audioPlayer.play()
                audioPlayers[noise] = audioPlayer
                selectedPlayers.append(noise)
            } catch {
                print(error.localizedDescription)
            }
            for (noise, player) in audioPlayers {
                if selectedPlayers.contains(noise) && player.isPlaying == false {
                    player.play()
                }
            }
        }
        updateButtons()
        collectionView.reloadItems(at: [indexPath])
    }
    
}

extension MainViewController: PlaybackControlsToolbarDelegate {
    
    func openTimerViewButtonDidPress() {
        openTimePickerController()
    }
    
    func playPauseButtonDidPress() {
        togglePlayback()
    }
    
    func openMixerDidPress() {
        openMixerViewController()
    }
    
}

extension MainViewController: TimePickerControllerDelegate {
    
    func get(selectedSeconds: Int) {
        timer.createTimer(with: selectedSeconds)
        timer.delegate = self
        self.selectedSeconds = selectedSeconds
        timePickerVC?.timePickerView.setTimeLabelText(with: selectedSeconds)
        playbackControlsToolbar.setTimeLabelText(with: selectedSeconds)
    }
    
    func deleteTimer() {
        timer.cancelTimer()
        isTimerActive = false
        playbackControlsToolbar.hideTimeLabel()
    }
    
}

extension MainViewController: MixerViewControllerDelegate {
    
    func setPlayerVolume(playerName: String, playerVolume: Float) {
        if let player = audioPlayers[playerName] {
            player.volume = playerVolume
            selectedPlayersVolume[playerName] = playerVolume
        }
    }
    
    func removePlayerWith(playerName: String) {
        if let player = audioPlayers[playerName] {
            player.stop()
            
            for player in selectedPlayers {
                if player == playerName, let playerIndex = selectedPlayers.firstIndex(of: player) {
                    selectedPlayers.remove(at: playerIndex)
                }
            }
            
            if let playerIndex =  noises.firstIndex(of: playerName) {
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

extension MainViewController: RelaxTimerDelegate {
    
    func get(remainingSeconds: Int, isTimerActive: Bool) {
        seconds = remainingSeconds
        self.isTimerActive = isTimerActive
        print("Main \(seconds), isTimerActive \(isTimerActive)")
        
        playbackControlsToolbar.setTimeLabelText(with: seconds)
        timePickerVC?.timePickerView.setTimeLabelText(with: seconds)
        timePickerVC?.remainingSeconds = seconds
        
        if !isTimerActive {
            audioPlayers = audioPlayers.mapValues{ player in
                if player.isPlaying{
                    player.stop()
                }
                return player
            }
            deleteTimer()
            updateButtons()
            timePickerVC?.setTimePickerMode()
        }
    }
    
}
