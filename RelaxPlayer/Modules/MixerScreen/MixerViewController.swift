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
    
    private var selectedPlayers = [String]()
    private var selectedPlayersVolume = [String : Float]()
    
    private var impactGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private var okAction: UIAlertAction!
    
    init(players: [String], playersVolume: [String : Float]) {
        super.init(nibName: nil, bundle: nil)
        
        self.selectedPlayers = players
        self.selectedPlayersVolume = playersVolume
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
            textField.font = UIFont(name: "AvenirNext-Regular", size: 15)
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        okAction = UIAlertAction(title: "Ok", style: .default) { action in
            guard let mixName = alertController.textFields?.first?.text else { return }
            CoreDataStore.shared.saveMix(name: mixName,
                                         players: self.selectedPlayers,
                                         playersVolume: self.selectedPlayersVolume)
            self.navigationController?.popViewController(animated: true)
        }
        okAction.isEnabled = false
        alertController.addAction(cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true)
        impactGenerator.impactOccurred()
    }
    
    @objc private func textFieldDidChange(_ field: UITextField) {
        okAction.isEnabled = field.text?.count ?? 0 > 0
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
        selectedPlayers.removeAll()
        selectedPlayersVolume.removeAll()
        tableView.reloadData()
        impactGenerator.impactOccurred()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MixerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedPlayers.isEmpty {
            navigationController?.popViewController(animated: true)
        }
        return selectedPlayers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MixerCell.reuseId,
                                                    for: indexPath) as? MixerCell {
            let player = selectedPlayers[indexPath.row]
            if let volumeValue = selectedPlayersVolume[player] {
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

// MARK: - MixerCellDelegate
extension MixerViewController: MixerCellDelegate {

    func removePlayer(name: String) {
        if let playerNameIndex = selectedPlayers.firstIndex(of: name) {
            selectedPlayers = selectedPlayers.filter {$0 != name}
            delegate?.removePlayer(name: name)
            let indexPath = IndexPath(item: playerNameIndex, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            impactGenerator.impactOccurred()
        }
    }

    func setPlayerVolume(name: String, volume: Float) {
        delegate?.setPlayerVolume(name: name, volume: volume)
        selectedPlayersVolume[name] = volume
    }
}
