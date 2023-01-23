//
//  TableManager.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.01.2023.
//

import UIKit

protocol MixerPresenterOut: AnyObject {
    func cleanTableView()
}

// MARK: - TableManager
class TableManager: NSObject {
    
    weak var presenter: MixerPresenterIn?
    private let tableView: UITableView
    private var noises = [String]()
    private var noisesVolume: [String : Float]
    
    init(tableView: UITableView, noises: [String], noisesVolume: [String : Float]) {
        self.tableView = tableView
        self.noises = noises
        self.noisesVolume = noisesVolume
        super.init()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(MixerNoiseCell.self, forCellReuseIdentifier: MixerNoiseCell.reuseId)
        self.tableView.separatorInset = .zero
        self.tableView.allowsSelection = false
        self.tableView.backgroundColor = .clear
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TableManager: UITableViewDataSource, UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noises.isEmpty {
            presenter?.tableViewCleaned()
        }
        return noises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MixerNoiseCell.reuseId,
                                                    for: indexPath) as? MixerNoiseCell {
            let noiseName = noises[indexPath.row]
            cell.delegate = self
            cell.configure(from: noiseName)
            
            if let volumeValue = noisesVolume[noiseName] {
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

// MARK: - MixerPresenterOut
extension TableManager: MixerPresenterOut {
    
    func cleanTableView() {
        noises.removeAll()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - MixerNoiseCellDelegate
extension TableManager: MixerNoiseCellDelegate {
    
    func changePlayerVolume(playerName: String, playerVolume: Float) {
        presenter?.setPlayerVolume(playerName: playerName, playerVolume: playerVolume)
    }
    
    func deletePlayerButtonPrassed(playerName: String) {
        if let playerNameIndex = noises.firstIndex(of: playerName) {
            noises = noises.filter {$0 != playerName}
            presenter?.removePlayerWith(playerName: playerName)
            let indexPath = IndexPath(item: playerNameIndex, section: 0)
            
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
