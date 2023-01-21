//
//  MixerView.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.01.2023.
//

import UIKit

protocol MixerViewIn: AnyObject {
    func backToMainView()
}

class MixerView: UIViewController {
    
    // MARK: - properties
    weak var mainView: MainViewIn?
    private let presenter: MixerViewOut
    private let tableView: UITableView
    private var removeAllPlayersButton = UIButton()
    private let backgroundBlurView = UIVisualEffectView()

    // MARK: - init
    init(presenter: MixerViewOut, tableView: UITableView) {
        self.presenter = presenter
        self.tableView = tableView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundBlurView)
        backgroundBlurView.frame = view.bounds
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        backgroundBlurView.effect = blurEffect
    
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        setupCleanButton()
    }
    
    // MARK: - methods
    private func setupCleanButton() {
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
        configuration.baseBackgroundColor = .red
        removeAllPlayersButton.configuration = configuration
        removeAllPlayersButton.addTarget(self, action: #selector(cleanTableView), for: .touchUpInside)
    }
    
    @objc
    private func cleanTableView() {
        presenter.cleanTableView()
    }
}

// MARK: - MixerViewIn
extension MixerView: MixerViewIn {

    func backToMainView() {
        guard let mainView = mainView else { return }
        mainView.dismiss()
    }
}
