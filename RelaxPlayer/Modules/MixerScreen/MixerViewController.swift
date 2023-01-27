//
//  MixerViewController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.01.2023.
//

import UIKit

protocol TableManagerOut: AnyObject {
    func removeAllPlayers()
    func removePlayer(name: String)
    func setPlayerVolume(name: String, volume: Float)
}

class MixerViewController: UIViewController {
    
    // MARK: - Properties
    weak var presenter: MixerViewControllerOut?
    private let tableManager: TableManagerIn
    private let tableView: UITableView
   
    // MARK: - init
    init(tableManager: TableManagerIn, tableView: UITableView) {
        self.tableManager = tableManager
        self.tableView = tableView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundBlurView = UIVisualEffectView()
        view.addSubview(backgroundBlurView)
        backgroundBlurView.frame = view.bounds
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        backgroundBlurView.effect = blurEffect
    
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        setupCleanButton()
    }
    
    // MARK: - Private Methods
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
        tableManager.cleanTableView()
    }
}

// MARK: - TableManagerOut
extension MixerViewController: TableManagerOut {
    
    func removeAllPlayers() {
        presenter?.removeAllPlayers()
    }
    
    func removePlayer(name: String) {
        presenter?.removePlayer(name: name)
    }
    
    func setPlayerVolume(name: String, volume: Float) {
        presenter?.setPlayerVolume(name: name, volume: volume)
    }
}
