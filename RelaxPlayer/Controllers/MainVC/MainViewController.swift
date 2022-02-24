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
    
    var timer: Timer?
    var isTimerStarted = false
    var seconds = Int()
    
    weak var timePickerVC: TimePickerController?
    
    //  MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupPlaybackControlsToolbar()
        
    }
    
    //  MARK: - setup collection view
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: createNoisesSection())
        collectionView.register(MainNoiseCell.self, forCellWithReuseIdentifier: MainNoiseCell.reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
    }
    
    //  MARK: - setup layout section
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
        self.present(UINavigationController(rootViewController: timePickerVC), animated: true, completion: nil)
    }
    
    //  MARK: - setup timer
    func createTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1,
                                          target: self,
                                          selector: #selector(timerAction),
                                          userInfo: nil,
                                          repeats: true)
        guard let timer = self.timer else { return }
        timer.tolerance = 0.1
        RunLoop.current.add(timer, forMode: .common)
    }
    
    //  MARK: - timer action
    @objc func timerAction() {
        seconds -= 1
        
        if seconds == 0 {
            audioPlayers = audioPlayers.mapValues{ player in
                if player.isPlaying{
                    player.stop()
                }
                return player
            }
            timer?.invalidate()
            timer = nil
        }
        
        playbackControlsToolbar.setTimeLabelText(with: seconds)
        print("MainVC \(seconds)")
        
 
        timePickerVC?.remainingSeconds = seconds
        
    }
    
    func togglePlayback() {
        for playerName in selectedPlayers {
            audioPlayers[playerName]?.toggle()
        }
        updateButtons()
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
        playbackControlsToolbar.playPauseButton.configuration?.image = UIImage(systemName: isAudioPlaying ? "pause.fill" : "play.fill")
    }
    
}

//  MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        noises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)-> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainNoiseCell.reuseId,
                                                         for: indexPath) as? MainNoiseCell {
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

//  MARK: - PlaybackControlsToolbarDelegate
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

//  MARK: - TimePickerControllerDelegate
extension MainViewController: TimePickerControllerDelegate {
    func get(selectedSeconds: Int) {
        self.seconds = selectedSeconds
        self.createTimer()
    }
    
    func deleteTimer() {
        timer?.invalidate()
        timer = nil
    }
}

//  MARK: - MixerViewControllerDelegate
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
