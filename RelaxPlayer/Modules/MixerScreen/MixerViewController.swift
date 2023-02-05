//
//  MixerViewController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.01.2023.
//

import UIKit

protocol MixerViewControllerDelegate: AnyObject {
    func removeAllPlayers()
    func removePlayer(name: String)
    func setPlayerVolume(name: String, volume: Float)
}

class MixerViewController: UIViewController {
    
    weak var delegate: MixerViewControllerDelegate?
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var players = [String]()
    private var playersVolume: [String : Float]
    
    init(players: [String], playersVolume: [String : Float]) {
        self.players = players
        self.playersVolume = playersVolume
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.backgroundColor = UIColor(named: "foregroundColor")
        navigationItem.titleView = UIImageView(image: UIImage(systemName: "slider.horizontal.3"))
        navigationItem.titleView?.tintColor = .white
        
        let backgroundBlurView = UIVisualEffectView()
        view.addSubview(backgroundBlurView)
        backgroundBlurView.frame = view.bounds
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        backgroundBlurView.effect = blurEffect
    
        setupTableView()
        setupCleanButton()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MixerCell.self, forCellReuseIdentifier: MixerCell.reuseId)
        tableView.separatorInset = .zero
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
    }
    
    private func setupCleanButton() {
        let removeAllPlayersButton = UIButton()
        view.addSubview(removeAllPlayersButton)
        removeAllPlayersButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeAllPlayersButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            removeAllPlayersButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
                                                           constant: -48)
        ])
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "trash")
        configuration.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .systemRed
        removeAllPlayersButton.configuration = configuration
        removeAllPlayersButton.addTarget(self, action: #selector(cleanTableView), for: .touchUpInside)
    }
    
    @objc
    private func cleanTableView() {
        delegate?.removeAllPlayers()
        players.removeAll()
        tableView.reloadData()
    }
}

// MARK: - MixerCellDelegate
extension MixerViewController: MixerCellDelegate {

    func removePlayer(name: String) {
        if let playerNameIndex = players.firstIndex(of: name) {
            players = players.filter {$0 != name}
            delegate?.removePlayer(name: name)
            let indexPath = IndexPath(item: playerNameIndex, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func setPlayerVolume(name: String, volume: Float) {
        delegate?.setPlayerVolume(name: name, volume: volume)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MixerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if players.isEmpty {
            dismiss(animated: true, completion: nil)
        }
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MixerCell.reuseId,
                                                    for: indexPath) as? MixerCell {

            let player = players[indexPath.row]
            if let volumeValue = playersVolume[player] {
                cell.configure(from: player, volume: volumeValue)
            }
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
}
