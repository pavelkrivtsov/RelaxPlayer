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
    var buttonsStack = UIStackView()
    var playbackControlsToolbar = PlaybackControlsToolbar()
    var timer: Timer?
    var isTimerStarted = false
    var counter = 0
    var selectedTimeNumber = 0
    weak var timerVC: TimePickerController?
    var playPauseButton = UIButton()
    var mixerButton = UIButton()

    // MARK: Configure view
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupButtonsStack()
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
        collectionView.register(MainNoiseCell.self, forCellWithReuseIdentifier: MainNoiseCell.reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
    }

    //TODO: better name "buttons stack"
    func setupButtonsStack() {
        collectionView.addSubview(buttonsStack)
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            buttonsStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
        ])
        buttonsStack.spacing = 20
        buttonsStack.alignment = .center
        buttonsStack.distribution = .fillEqually
        buttonsStack.backgroundColor = .systemGray5
        buttonsStack.layer.cornerRadius = 15

        playbackControlsToolbar.delegate = self
        collectionView.addSubview(playbackControlsToolbar)
        NSLayoutConstraint.activate([
            playbackControlsToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            playbackControlsToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            playbackControlsToolbar.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -30),
        ])

        // Play/Pause
        buttonsStack.addArrangedSubview(playPauseButton)
        var playPauseButtonConfiguration = UIButton.Configuration.plain()
        playPauseButtonConfiguration.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        playPauseButtonConfiguration.image = UIImage(systemName: "stop.fill")
        playPauseButton.configuration = playPauseButtonConfiguration
        playPauseButton.isEnabled = false
        playPauseButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)

        // Mixer
        buttonsStack.addArrangedSubview(mixerButton)
        var mixerButtonConfiguration = UIButton.Configuration.plain()
        mixerButtonConfiguration.image = UIImage(systemName: "slider.horizontal.3")
        mixerButton.configuration = mixerButtonConfiguration
        mixerButton.isEnabled = false
        mixerButton.addTarget(self, action: #selector(openMixerViewController), for: .touchUpInside)
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

    @objc func openTimePickerController() {
        let timerVC = TimePickerController()

        timerVC.counterOnCompletion = { [weak self, weak timerVC] counter in
            guard let self = self else {
                return
            }
            self.counter = counter
            self.selectedTimeNumber = counter
            self.createTimer()
            timerVC?.timer = self.timer
            self.timerVC = timerVC
        }
        timerVC.onStoppedTimer = { [weak self] in
            guard let self = self else {
                return
            }
            self.isTimerStarted = false
            self.playbackControlsToolbar.hideTimerLabel()
        }

        if isTimerStarted {
            timerVC.isTimerStarted = true
            timerVC.timer = timer
            timerVC.counter = self.counter
            timerVC.selectedTimeNumber = self.selectedTimeNumber
            self.timerVC = timerVC
        }

        present(UINavigationController(rootViewController: timerVC), animated: true, completion: nil)
    }

    func createTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1,
            target: self,
            selector: #selector(timerAction),
            userInfo: nil,
            repeats: true)
        guard let timer = self.timer else {
            return
        }
        timer.tolerance = 0.1
        RunLoop.current.add(timer, forMode: .common)
    }

    @objc func timerAction() {
        counter -= 1
        if counter == 0 {
            timer?.invalidate()
            timer = nil
            self.isTimerStarted = false
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            for (_, player) in audioPlayers {
                if player.isPlaying {
                    player.stop()
                }
            }
            self.timerVC?.isTimerStarted = false
            self.timerVC?.viewWillAppear(true)
        } else {
            self.isTimerStarted = true
        }
        self.timerVC?.timeLabelDisplayMode(accordingToThe: counter)
        playbackControlsToolbar.setTimerLabelText(with: counter)
        print(counter)
    }

    @objc func togglePlayback() {
        for playerName in selectedPlayers {
            audioPlayers[playerName]?.toggle()
        }
        updateButtons()
    }

    //  MARK: - setup mixer button
    @objc func openMixerViewController() {
        let mixerVC = MixerViewController()
        mixerVC.players = selectedPlayers.map { name in
            (name, audioPlayers[name]?.volume ?? 0)
        }

        mixerVC.volumeValue = { [weak self] playerName, volumeValue in
            guard let self = self, let player = self.audioPlayers[playerName] else {
                return
            }
            player.volume = volumeValue
        }

        mixerVC.handleDeletedPlayer = { [weak self] playerName in
            guard let self = self, let player = self.audioPlayers[playerName] else {
                return
            }
            player.stop()

            for player in self.selectedPlayers {
                if player == playerName, let playerIndex = self.selectedPlayers.firstIndex(of: player) {
                    self.selectedPlayers.remove(at: playerIndex)
                }
            }

            if let playerIndex = self.noises.firstIndex(of: playerName) {
                let indexPath = IndexPath(item: playerIndex, section: 0)
                self.collectionView.reloadItems(at: [indexPath])
            }
            self.updateButtons()
        }

        mixerVC.handleDeletedPlayers = { [weak self] cleanAllPlayers in
            guard let self = self else {
                return
            }
            self.selectedPlayers.removeAll()
            for (_, player) in self.audioPlayers {
                if player.isPlaying {
                    player.stop()
                }
            }
            self.collectionView.reloadData()
            self.updateButtons()
        }
        present(UINavigationController(rootViewController: mixerVC), animated: true, completion: nil)
    }

}

//  MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        noises.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
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
                guard let audioPath = Bundle.main.path(forResource: noise, ofType: "mp3") else {
                    return
                }
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

    //TODO better naming
    func updateButtons() {
        let isAudioPlaying = audioPlayers
                .values
                .filter {
                    $0.isPlaying
                }
                .count > 0
        playPauseButton.isEnabled = isAudioPlaying
        mixerButton.isEnabled = isAudioPlaying

        if isAudioPlaying {
            playbackControlsToolbar.updateVisualState(withPlayPauseIcon: .Pause)
        } else {
            playbackControlsToolbar.updateVisualState(withPlayPauseIcon: selectedPlayers.count > 0 ? .Playing : .Stop)
        }
        playPauseButton.setImage(UIImage(systemName: isAudioPlaying ? "pause.fill" : "stop.fill"), for: .normal)
    }
}


extension MainViewController: PlaybackControlsToolbarDelegate {
    func playPauseButtonDidPress() {
        togglePlayback()
    }

    func openMixerDidPress() {
        openMixerViewController()
    }

    func openTimerViewButtonDidPress() {
        openTimePickerController()
    }
}