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
    var noises = [String]()
    var selectedPlayersVolume = [String : Float]()
    var volumeValue: ((String, Float) -> ())?
    var handleDeletedPlayer: ((String) -> ())?
    
    //  MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Mixer"
        setupTableView()
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
    }
    
}

//  MARK: - UITableViewDelegate, UITableViewDataSource
extension MixerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MixerNoiseCell.reuseId,
                                                    for: indexPath) as? MixerNoiseCell {
            let noiseName = noises[indexPath.row]
            cell.noiseName = noiseName
            cell.iconImageView.image = UIImage(named: noiseName)
            
            for (noise, value) in selectedPlayersVolume {
                if noise == noiseName {
                    cell.volumeSlider.value = value
                    print(cell.volumeSlider.value)
                }
            }
            
            cell.volumeOnCompletion = { [weak self] playerName, volumeValue in
                guard let self = self else { return }
                self.volumeValue?(playerName, volumeValue)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, _ in
            let noise = self.noises[indexPath.row]
            self.noises = self.noises.filter {$0 != noise}
            self.handleDeletedPlayer?(noise)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let swipe = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipe
    }
    
}
