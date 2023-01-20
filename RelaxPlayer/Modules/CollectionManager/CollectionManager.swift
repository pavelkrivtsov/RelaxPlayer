//
//  CollectionManager.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 13.01.2023.
//

import UIKit
import AVFoundation


protocol MainPresenterOut: AnyObject {
    func togglePlayback()
}

class CollectionManager: NSObject {
    
    weak var presenter: MainPresenterIn?
    private let collectionView: UICollectionView
    private var noises = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    private var audioSassion = AVAudioSession.sharedInstance()
    private var audioPlayers = [String: AVAudioPlayer]()
    private var selectedPlayers = [String]()
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        
        self.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: createNoisesSection())
        self.collectionView.register(MainNoiseCell.self, forCellWithReuseIdentifier: MainNoiseCell.reuseId)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .clear
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
    
    private func updateButtons() {

        let isAudioPlaying = audioPlayers
            .values
            .filter { $0.isPlaying }
            .count > 0
        
        let isPlayerSelected = selectedPlayers.count > 0 ? true : false
        
        presenter?.updateButtons(isAudioPlaying: isAudioPlaying,
                                 isPlayerSelected: isPlayerSelected)
    }
}

// MARK: - UICollectionViewDataSource
extension CollectionManager: UICollectionViewDataSource {
    
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
}

// MARK: - UICollectionViewDelegate
extension CollectionManager: UICollectionViewDelegate {
    
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

// MARK: - MainPresenterOut
extension CollectionManager: MainPresenterOut {
    
    func togglePlayback() {
        for playerName in selectedPlayers {
            audioPlayers[playerName]?.toggle()
        }
        updateButtons()
    }
}
