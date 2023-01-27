//
//  TableManager.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.01.2023.
//

import UIKit

protocol TableManagerIn: AnyObject {
    func cleanTableView()
}

// MARK: - TableManager
class TableManager: NSObject {
    
    weak var view: TableManagerOut?
    private let tableView: UITableView
    private var players = [String]()
    private var playersVolume: [String : Float]
    
    init(tableView: UITableView, players: [String], playersVolume: [String : Float]) {
        self.tableView = tableView
        self.players = players
        self.playersVolume = playersVolume
        super.init()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(MixerCell.self, forCellReuseIdentifier: MixerCell.reuseId)
        self.tableView.separatorInset = .zero
        self.tableView.allowsSelection = false
        self.tableView.backgroundColor = .clear
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TableManager: UITableViewDataSource, UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if players.isEmpty {
            view?.removeAllPlayers()
        }
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MixerCell.reuseId,
                                                    for: indexPath) as? MixerCell {
            let player = players[indexPath.row]
            cell.tableManager = self
            cell.configure(from: player)
            
            if let volumeValue = playersVolume[player] {
                cell.volumeSlider.value = volumeValue
                print(cell.volumeSlider.value)
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
}

// MARK: - TableManagerIn
extension TableManager: TableManagerIn {
    
    func cleanTableView() {
        players.removeAll()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - MixerCellOut
extension TableManager: MixerCellOut {
    
    func changePlayerVolume(name: String, volume: Float) {
        view?.setPlayerVolume(name: name, volume: volume)
    }
    
    func removePlayer(name: String) {
        if let playerNameIndex = players.firstIndex(of: name) {
           
            let indexPath = IndexPath(item: playerNameIndex, section: 0)
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            players = players.filter {$0 != name}
            view?.removePlayer(name: name)
        }
    }
}
