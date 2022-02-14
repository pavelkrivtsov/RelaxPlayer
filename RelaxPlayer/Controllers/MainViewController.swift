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
    var noises = ["1","2","3","4","5","6","7","8","9","10"]
    var audioSassion = AVAudioSession.sharedInstance()
    var audioPlayers = [String: AVAudioPlayer]()
    var selectedPlayers = [String]()
    var buttonsStack = UIStackView()
    var timerButton = UIButton()
    var timer: Timer?
    var isTimerStarted = false
    var counter = 0
    var selectedTimeNumber = 0
    weak var timerVC: TimePickerController?
    var playPauseButton = UIButton()
    var mixerButton = UIButton()
    var selectedPlayersVolume = [String:Float]()
    
    //  MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupButtonsStack()
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
    
    //  MARK: - setup button stack
    func setupButtonsStack() {
        collectionView.addSubview(buttonsStack)
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            buttonsStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            buttonsStack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
        ])
        buttonsStack.spacing = 20
        buttonsStack.alignment = .center
        buttonsStack.distribution = .fillEqually
        buttonsStack.backgroundColor = .systemGray5
        buttonsStack.layer.cornerRadius = 15
        setupTimerButton()
        setupPlayPauseButton()
        setupMixerButton()
    }
    
    //  MARK: - setup timer button
    func setupTimerButton() {
        buttonsStack.addArrangedSubview(timerButton)
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "timer")
        timerButton.configuration = configuration
        timerButton.addTarget(self, action: #selector(timerButtonTapped), for: .touchUpInside)
    }
    
    @objc func timerButtonTapped() {
        let timerVC = TimePickerController()
        
        if isTimerStarted {
            timerVC.isTimerStarted = true
            timerVC.timer = timer
            timerVC.counter = self.counter
            timerVC.selectedTimeNumber = self.selectedTimeNumber
            self.timerVC = timerVC
            
            timerVC.counterOnCompletion = { [weak self, weak timerVC] counter in
                guard let self = self else { return }
                self.counter = counter
                self.selectedTimeNumber = counter
                self.createTimer()
                timerVC?.timer = self.timer
                self.timerVC = timerVC
            }
            timerVC.isTimerStartedOnCompletion = { [weak self] isTimerStarted in
                guard let self = self else { return }
                self.isTimerStarted = isTimerStarted
                print("isTimerStarted \(self.isTimerStarted)")
                var configuration = UIButton.Configuration.plain()
                configuration.image = UIImage(systemName: "timer")
                configuration.imagePlacement = .top
                self.timerButton.configuration = configuration
            }
        } else {
            timerVC.counterOnCompletion = { [weak self, weak timerVC] counter in
                guard let self = self else { return }
                self.counter = counter
                self.selectedTimeNumber = counter
                self.createTimer()
                timerVC?.timer = self.timer
                self.timerVC = timerVC
                print("self.isTimerStarted \(self.isTimerStarted)")
            }
            timerVC.isTimerStartedOnCompletion = { [weak self] isTimerStarted in
                guard let self = self else { return }
                self.isTimerStarted = isTimerStarted
                print("isTimerStarted \(self.isTimerStarted)")
                var configuration = UIButton.Configuration.plain()
                configuration.image = UIImage(systemName: "timer")
                configuration.imagePlacement = .top
                self.timerButton.configuration = configuration
            }
        }
        self.present(UINavigationController(rootViewController: timerVC), animated: true, completion: nil)
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
        self.timeLabelDisplayMode(accordingToThe: counter)
        print(counter)
    }
    
    //  MARK: - time label display mode
    func timeLabelDisplayMode(accordingToThe counter: Int) {
        let hours = counter / 3600
        let minutes = counter / 60 % 60
        let seconds = counter % 60
        var timeString = ""
        
        if counter < 3600 {
            timeString = NSString(format: "%0.2d:%0.2d", minutes, seconds) as String
            var configuration = UIButton.Configuration.plain()
            configuration.image = UIImage(systemName: "timer")
            configuration.imagePlacement = .top
            configuration.subtitle = timeString
            timerButton.configuration = configuration
        } else {
            timeString = NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
            var configuration = UIButton.Configuration.plain()
            configuration.image = UIImage(systemName: "timer")
            configuration.imagePlacement = .top
            configuration.subtitle = timeString
            timerButton.configuration = configuration
        }
    }
    
    //  MARK: - setup play/pause button
    func setupPlayPauseButton() {
        buttonsStack.addArrangedSubview(playPauseButton)
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        configuration.image = UIImage(systemName: "stop.fill")
        playPauseButton.configuration = configuration
        playPauseButton.isEnabled = false
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
    }
    @objc func playPauseButtonTapped() {
        for (noise, player) in audioPlayers {
            if selectedPlayers.contains(noise) {
                if player.isPlaying {
                    player.pause()
                } else {
                    player.play()
                }
                playPauseButton.setImage(UIImage(systemName: player.isPlaying ? "pause.fill" : "play.fill"),
                                         for: .normal)
            }
        }
    }
    
    //  MARK: - setup mixer button
    func setupMixerButton() {
        buttonsStack.addArrangedSubview(mixerButton)
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "slider.horizontal.3")
        mixerButton.configuration = configuration
        mixerButton.isEnabled = false
        mixerButton.addTarget(self, action: #selector(mixerButtonTapped), for: .touchUpInside)
    }
    
    @objc func mixerButtonTapped() {
        let mixerVC = MixerViewController()
        mixerVC.noises = self.selectedPlayers
        mixerVC.selectedPlayersVolume = selectedPlayersVolume
        
        mixerVC.volumeValue = { [weak self] playerName, volumeValue  in
            guard let self = self, let player = self.audioPlayers[playerName] else { return }
            player.volume = volumeValue
            self.selectedPlayersVolume[playerName] = volumeValue
        }
        
        mixerVC.handleDeletedPlayer = { [weak self] playerName in
            guard let self = self, let player = self.audioPlayers[playerName] else { return }
            player.stop()
            
            for player in self.selectedPlayers {
                if player == playerName, let playerIndex = self.selectedPlayers.firstIndex(of: player) {
                    self.selectedPlayers.remove(at: playerIndex)
                }
            }
            
            if let playerIndex =  self.noises.firstIndex(of: playerName) {
                let indexPath = IndexPath(item: playerIndex, section: 0)
                self.collectionView.reloadItems(at: [indexPath])
            }
            self.updateButtons()
        }
        
        mixerVC.handleDeletedPlayers = { [weak self] cleanAllPlayers in
            guard let self = self else { return }
            self.selectedPlayers.removeAll()
            self.selectedPlayersVolume.removeAll()
            for (_, player) in self.audioPlayers {
                if player.isPlaying {
                    player.stop()
                }
            }
            self.collectionView.reloadData()
            self.updateButtons()
        }
        self.present(UINavigationController(rootViewController: mixerVC), animated: true, completion: nil)
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
        
        guard collectionView.cellForItem(at: indexPath) != nil else {return}
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
    
    func updateButtons() {
        if selectedPlayers.isEmpty {
            playPauseButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            playPauseButton.isEnabled = false
            mixerButton.isEnabled = false
        } else {
            for (_, player) in audioPlayers {
                if player.isPlaying {
                    playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                    playPauseButton.isEnabled = true
                    mixerButton.isEnabled = true
                }
            }
        }
    }
    
}



