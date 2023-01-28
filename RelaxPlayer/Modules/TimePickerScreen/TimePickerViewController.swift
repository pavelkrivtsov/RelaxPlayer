//
//  TimePickerViewController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 23.01.2023.
//

import UIKit

// MARK: - TimePickerVC
class TimePickerViewController: UIViewController {
    
    // MARK: - Properties
    weak var presenter: TimePickerViewControllerOut?
    private var timePickerView = TimePickerView()
    private var playPauseButton = UIButton()
    private let backgroundBlurView = UIVisualEffectView()
    private var configuration = UIButton.Configuration.filled()
    
    var isTimerActive = Bool()
    private var seconds = Int()
    private var value = Double()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(backgroundBlurView)
        backgroundBlurView.frame = view.bounds
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        backgroundBlurView.effect = blurEffect
        
        setupTimePickerView()
        setupPlayPauseButton()
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isTimerActive {
            DispatchQueue.main.async {
                self.timePickerView.startCountdownMode(seconds: self.seconds, value: self.value)
            }
        }
    }
    
    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timePickerView.createBackgroundShapeLayer()
        timePickerView.createForegroundShapeLayer()
    }
    
    // MARK: - Private methods
    private func setupTimePickerView() {
        view.addSubview(timePickerView)
        NSLayoutConstraint.activate([
            timePickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            timePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            timePickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        timePickerView.view = self
    }
    
    private func setupPlayPauseButton() {
        view.addSubview(playPauseButton)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
                                                           constant: -48)
        ])
        playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed), for: .touchUpInside)
        configuration.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        configuration.cornerStyle = .capsule
        stopCountdownMode()
    }
    
    @objc
    private func playPauseButtonPressed() {
        presenter?.togglePlayPause()
    }
}

extension TimePickerViewController {
    
    func startCountdownMode(seconds: Int, value: Double) {
        self.seconds = seconds
        self.value = value
        timePickerView.startCountdownMode(seconds: seconds, value: value)
    }
    
    func prepareCountdownMode(with seconds: Int) {
        timePickerView.prepareCountdownMode(with: seconds)
        
        configuration.image = UIImage(systemName: "stop")
        configuration.baseBackgroundColor = .systemRed
        playPauseButton.configuration = configuration
    }
        
    func stopCountdownMode() {
        timePickerView.stopCountdownMode()

        configuration.image = UIImage(systemName: "play")
        configuration.baseBackgroundColor = .systemBlue
        playPauseButton.configuration = configuration
    }
}

// MARK: - TimePickerViewOut
extension TimePickerViewController: TimePickerViewOut {
    
    func getFromTimePicker(selectedSeconds: Int) {
        presenter?.getFromTimePicker(selectedSeconds: selectedSeconds)
    }
}


