//
//  MixerViewController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 30.12.2021.
//

import UIKit

protocol MixerViewControllerDelegate: AnyObject {
    func removeAllPlayers()
    func removePlayerWith(playerName: String)
    func setPlayerVolume(playerName: String, playerVolume: Float)
}

class MixerViewController: UIViewController {
    
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    var removeAllPlayersButton = UIButton()
    var noises = [String]()
    var selectedPlayersVolume = [String : Float]()
    let backgroundBlurView = UIVisualEffectView()
    weak var delegate: MixerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = .systemGray
        navigationItem.titleView = UIImageView(image: UIImage(systemName: "slider.horizontal.3"))
        navigationItem.titleView?.tintColor = .white
        setupBackgroundBlurView()
        setupTableView()
        setupCleanButton()
    }
    
    fileprivate func setupBackgroundBlurView() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        view.addSubview(backgroundBlurView)
        backgroundBlurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundBlurView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundBlurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundBlurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundBlurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        backgroundBlurView.effect = blurEffect
    }
    
    fileprivate func setupTableView() {
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
        tableView.backgroundColor = .clear
    }
    
    fileprivate func setupCleanButton() {
        view.addSubview(removeAllPlayersButton)
        removeAllPlayersButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeAllPlayersButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            removeAllPlayersButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                                                           constant: -50)
        ])
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "trash")
        configuration.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        configuration.buttonSize = .large
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .red
        removeAllPlayersButton.configuration = configuration
        removeAllPlayersButton.addTarget(self, action: #selector(removeAllPlayers), for: .touchUpInside)
    }
    
    @objc fileprivate func removeAllPlayers() {
        delegate?.removeAllPlayers()
        noises.removeAll()
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
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

// MARK: - MixerNoiseCellDelegate
extension MixerViewController: MixerNoiseCellDelegate {
    
    func changePlayerVolume(playerName: String, playerVolume: Float) {
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
