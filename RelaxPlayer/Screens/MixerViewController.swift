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
    var cleanButton = UIButton()
    var volumeValue: ((String, Float) -> ())?
    var handleDeletedPlayer: ((String) -> ())?
    var handleDeletedPlayers: ((Bool) -> ())?
    var players: [(String, Float)] = []

    //  MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mixer"
        setupTableView()
        setupCleanButton()
    }

    //  MARK: - setup table view
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

    //  MARK: - setup clean button
    func setupCleanButton() {
        view.addSubview(cleanButton)
        cleanButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cleanButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            cleanButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)

        ])
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.title = "Очистить"
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .large
        configuration.baseForegroundColor = .red
        configuration.baseBackgroundColor = .red
        cleanButton.configuration = configuration
        cleanButton.addTarget(self, action: #selector(cleanTableView), for: .touchUpInside)

    }

    @objc func cleanTableView() {
        handleDeletedPlayers?(true)
        self.players.removeAll()
        self.tableView.reloadData()
    }

}

//  MARK: - UITableViewDelegate, UITableViewDataSource
extension MixerViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if players.isEmpty {
            dismiss(animated: true, completion: nil)
        }
        return players.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MixerNoiseCell.reuseId,
            for: indexPath) as? MixerNoiseCell {
            let noiseName = players[indexPath.row].0
            cell.noiseName = noiseName
            cell.iconImageView.image = UIImage(named: noiseName)

            cell.volumeOnCompletion = { [weak self] playerName, volumeValue in
                guard let self = self else {
                    return
                }
                self.volumeValue?(playerName, volumeValue)
            }
            cell.volumeSlider.value = players[indexPath.row].1

            cell.deleteButton = { [weak self] playerName in
                guard let self = self else {
                    return
                }
                self.players.remove(at: indexPath.row)
                self.handleDeletedPlayer?(playerName)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

}
