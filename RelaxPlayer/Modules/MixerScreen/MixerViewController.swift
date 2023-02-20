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

final class MixerViewController: UIViewController {
    
    weak var delegate: MixerViewControllerDelegate?
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var players = [String]()
    private var playersVolume = [String : Float]()
    private var impactGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private var coreDataStore = CoreDataStore.shared
    
    init(players: [String], playersVolume: [String : Float]) {
        super.init(nibName: nil, bundle: nil)
        self.players = players
        self.playersVolume = playersVolume
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor")

        let button = UIBarButtonItem(image: .init(systemName: "square.and.arrow.down"),
                                     style: .done,
                                     target: self,
                                     action: #selector(showAlert))
        button.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = button
        
        setupTableView()
        setupCleanButton()
    }
    
    @objc
    private func showAlert() {
        let alertController = UIAlertController(title: "Add mix name", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.clearButtonMode = .whileEditing
            textField.autocorrectionType = .default
            textField.font = UIFont(name: "AvenirNext-UltraLight", size: 15)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let ok = UIAlertAction(title: "Ok", style: .default) { action in
            guard let mixName = alertController.textFields?.first?.text else { return }
            if mixName.isEmpty == false {
                self.coreDataStore.saveMix(name: mixName)
            }
        }
        alertController.addAction(cancel)
        alertController.addAction(ok)
        present(alertController, animated: true)
        impactGenerator.impactOccurred()
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
        impactGenerator.impactOccurred()
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
            impactGenerator.impactOccurred()
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
            navigationController?.popViewController(animated: true)
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
