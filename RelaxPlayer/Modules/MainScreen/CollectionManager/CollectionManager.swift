//
//  CollectionManager.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 13.01.2023.
//

import UIKit
import AVFoundation


protocol CollectionManagerIn: AnyObject {
    func togglePlayback()
    func getSelectedPlayers() -> [String]
    func getSelectedPlayersVolume() -> [String : Float]
    func removeAllPlayers()
    func removePlayer(name: String)
    func setPlayerVolume(name: String, volume: Float)
}

// MARK: - CollectionManager
class CollectionManager: NSObject {
    
    weak var presenter: CollectionManagerOut?
    private let collectionView: UICollectionView
    
    private var noiseNames = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    private var audioSassion = AVAudioSession.sharedInstance()
    private var players = [String: AVAudioPlayer]()
    private var selectedPlayers = [String]()
    private var selectedPlayersVolume = [String : Float]()
    
    // MARK: - Init
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        
        self.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: createNoisesSection())
        self.collectionView.register(NoiseCell.self, forCellWithReuseIdentifier: NoiseCell.reuseId)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .clear
    }
    
    // MARK: - Private mathods
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

        let isAudioPlaying = players
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
        noiseNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoiseCell.reuseId,
                                                         for: indexPath) as? NoiseCell {
            let name = noiseNames[indexPath.item]
            let player = players[name]
            cell.configure(imageWith: name, isSelected: player?.isPlaying ?? false)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionManager: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard collectionView.cellForItem(at: indexPath) != nil else { return }
        let name = noiseNames[indexPath.item]
        
        if let player = players[name] {
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
        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func createPlayer(with name: String) {
        do {
            guard let audioPath = Bundle.main.path(forResource: name, ofType: "mp3") else { return }
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
            player.numberOfLoops = -1
            player.volume = 1
            player.prepareToPlay()
            players[name] = player
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func activateSelectedPlayers() {
        do {
            try audioSassion.setActive(true)
            for (name, player) in players {
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

// MARK: - CollectionManagerIn
extension CollectionManager: CollectionManagerIn {
           
    func togglePlayback() {
        for playerName in selectedPlayers {
            players[playerName]?.toggle()
        }
        updateButtons()
    }
    
    func getSelectedPlayers() -> [String] {
        selectedPlayers
    }
    
    func getSelectedPlayersVolume() -> [String : Float] {
        selectedPlayersVolume
    }
    
    func removeAllPlayers() {
        do {
            selectedPlayers.removeAll()
            selectedPlayersVolume.removeAll()
            players = players.mapValues{ player in
                if player.isPlaying{
                    player.stop()
                }
                return player
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            updateButtons()
            try audioSassion.setActive(false)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removePlayer(name: String) {
        guard let player = players[name] else { return }
        player.stop()
        removePlayerFromSelected(with: name)
        updateButtons()
        
        if let playerIndex = noiseNames.firstIndex(of: name) {
            let indexPath = IndexPath(item: playerIndex, section: 0)
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func setPlayerVolume(name: String, volume: Float) {
        if let player = players[name] {
            player.volume = volume
            selectedPlayersVolume[name] = volume
        }
    }
}
