//
//  MixerViewController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 30.12.2021.
//

import UIKit

class MixerViewController: UIViewController {
    
    //  MARK: - declaring variables
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    var removeAllPlayersButton = UIButton()
    var noises = [String]()
    var selectedPlayersVolume = [String : Float]()
    var volumeValue: ((String, Float) -> ())?
    
    weak var delegate: MixerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mixer"
        setupTableView()
        setupCleanButton()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MixerNoiseCell.self, forCellReuseIdentifier: MixerNoiseCell.reuseId)
        tableView.separatorInset = .zero
        tableView.allowsSelection = false
        tableView.backgroundColor = .systemGray6
    }
    
    func setupCleanButton() {
        view.addSubview(removeAllPlayersButton)
        removeAllPlayersButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeAllPlayersButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            removeAllPlayersButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.title = "Очистить"
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .large
        configuration.baseForegroundColor = .red
        configuration.baseBackgroundColor = .red
        removeAllPlayersButton.configuration = configuration
        removeAllPlayersButton.addTarget(self, action: #selector(removeAllPlayers), for: .touchUpInside)
        
    }
    
    @objc func removeAllPlayers() {
        delegate?.removeAllPlayers()
        noises.removeAll()
        tableView.reloadData()
    }
    
}


extension MixerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noises.isEmpty {
            dismiss(animated: true, completion: nil)
        }
        return noises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MixerNoiseCell.reuseId,
                                                    for: indexPath) as? MixerNoiseCell {
            let noiseName = noises[indexPath.row]
            cell.delegate = self
            cell.noiseName = noiseName
            cell.iconImageView.image = UIImage(named: noiseName)
            
            if let volumeValue = selectedPlayersVolume[noiseName] {
                cell.volumeSlider.value = volumeValue
                print(cell.volumeSlider.value)
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}


extension MixerViewController: MixerNoiseCellDelegate {
    
    func changePlayerVolume(playerName: String, playerVolume: Float) {
//        volumeValue?(playerName, playerVolume)
        delegate?.setPlayerVolume(playerName: playerName, playerVolume: playerVolume)
    }
    
    func deletePlayerButtonPrassed(playerName: String) {
        if let playerNameIndex = noises.firstIndex(of: playerName) {
            noises = noises.filter {$0 != playerName}
            delegate?.removePlayerWith(playerName: playerName)
            let indexPath = IndexPath(item: playerNameIndex, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
        
}

protocol MixerViewControllerDelegate: AnyObject {
    func removeAllPlayers()
    func removePlayerWith(playerName: String)
    func setPlayerVolume(playerName: String, playerVolume: Float)
}
