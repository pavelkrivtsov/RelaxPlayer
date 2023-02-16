//
//  TimePickerViewController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 23.01.2023.
//

import UIKit

protocol TimePickerViewControllerDelegate: AnyObject {
    func getSelectedSeconds(_ selectedSeconds: Int)
    func cancelTimer()
}

final class TimePickerViewController: UIViewController {
    
    weak var delegate: TimePickerViewControllerDelegate?
    private var timePickerView = TimePickerView()
    private var playPauseButton = UIButton()
    private var configuration = UIButton.Configuration.filled()
    private var isTimerActive = Bool()
    private var selectedSeconds = Int()
    private var remainingSeconds = Int()
    private lazy var impactGenerator = UIImpactFeedbackGenerator(style: .rigid)
 
    init(isTimerActive: Bool, selectedSeconds: Int, remainingSeconds: Int) {
        super.init(nibName: nil, bundle: nil)
        self.isTimerActive = isTimerActive
        self.selectedSeconds = selectedSeconds
        self.remainingSeconds = remainingSeconds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = UIColor(named: "foregroundColor")
        navigationItem.titleView = UIImageView(image: UIImage(systemName: "timer"))
        navigationItem.titleView?.tintColor = .white
        
        let backgroundBlurView = UIVisualEffectView()
        view.addSubview(backgroundBlurView)
        backgroundBlurView.frame = view.bounds
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        backgroundBlurView.effect = blurEffect
        
        setupTimePicker()
        setupPlayPauseButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isTimerActive {
            prepareCountdownMode(with: remainingSeconds)
            let currentValue = 1 - (Double(remainingSeconds) / Double(selectedSeconds))
            startCountdownMode(seconds: remainingSeconds, value: currentValue)
        } else {
            stopCountdownMode()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timePickerView.createBackgroundShapeLayer()
        timePickerView.createForegroundShapeLayer()
    }
    
    private func setupTimePicker() {
        view.addSubview(timePickerView)
        timePickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timePickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            timePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            timePickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        timePickerView.delegate = self
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
        configuration.image = UIImage(systemName: "play")
        configuration.baseBackgroundColor = .systemBlue
        playPauseButton.configuration = configuration
    }
    
    @objc
    private func playPauseButtonPressed() {
        isTimerActive.toggle()
        if isTimerActive {
            delegate?.getSelectedSeconds(selectedSeconds)
            prepareCountdownMode(with: selectedSeconds)
        } else {
            delegate?.cancelTimer()
            stopCountdownMode()
        }
        playPauseButton.configuration?.image = UIImage(systemName: isTimerActive ? "stop" : "play")
        impactGenerator.impactOccurred()
    }
    
    private func prepareCountdownMode(with seconds: Int) {
        timePickerView.prepareCountdownMode(with: seconds)
        configuration.image = UIImage(systemName: "stop")
        configuration.baseBackgroundColor = .systemRed
        playPauseButton.configuration = configuration
    }
}

extension TimePickerViewController {
    
    func startCountdownMode(seconds: Int, value: Double) {
        timePickerView.startCountdownMode(seconds: seconds, value: value)
    }

    func stopCountdownMode() {
        isTimerActive = false
        timePickerView.stopCountdownMode()
        configuration.image = UIImage(systemName: "play")
        configuration.baseBackgroundColor = .systemBlue
        playPauseButton.configuration = configuration
    }
}

// MARK: - TimePickerViewDelegate
extension TimePickerViewController: TimePickerViewDelegate {
    func getSelectedSeconds(_ seconds: Int) {
        selectedSeconds = seconds
    }
}
