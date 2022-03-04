//
//  TimePickerController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 30.12.2021.
//

import UIKit

class TimePickerController: UIViewController {
    
    var timePickerView = TimePickerView()
    var playPauseButton = UIButton()
    var isTimerActive = false
    var selectedSeconds = 60
    var remainingSeconds = Int()
    weak var delegate: TimePickerControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = "Timer"
        
        setupTimePicker()
        setupPlayPauseButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timePickerView.setDisplayMode(isTimerActive: isTimerActive)
        playPauseButton.configuration?.image = UIImage(systemName: isTimerActive ? "stop" : "play")
        
        if isTimerActive {
            let currentValue = 1 - (Double(remainingSeconds) / Double(selectedSeconds))
            timePickerView.startAnimation(by: currentValue)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timePickerView.createBackgroundShapeLayer()
        timePickerView.createForegroundShapeLayer()
    }
    
    private func setupTimePicker() {
        view.addSubview(timePickerView)
        NSLayoutConstraint.activate([
            timePickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timePickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        timePickerView.delegate = self
    }
    
    private func setupPlayPauseButton() {
        view.addSubview(playPauseButton)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.topAnchor.constraint(equalTo: timePickerView.bottomAnchor, constant: 20),
        ])
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        configuration.image = UIImage(systemName: "play")
        configuration.cornerStyle = .capsule
        playPauseButton.configuration = configuration
        playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed), for: .touchUpInside)
    }
    
    @objc func playPauseButtonPressed() {
        isTimerActive.toggle()
        if isTimerActive {
            delegate?.get(selectedSeconds: selectedSeconds)
            timePickerView.startAnimation()
        } else {
            delegate?.deleteTimer()
        }
        timePickerView.setDisplayMode(isTimerActive: isTimerActive)
        playPauseButton.configuration?.image = UIImage(systemName: isTimerActive ? "stop" : "play")
    }
    
}

extension TimePickerController {
    func setTimePickerMode() {
        isTimerActive = false
        timePickerView.setDisplayMode(isTimerActive: isTimerActive)
        playPauseButton.configuration?.image = UIImage(systemName: "play")
    }
}

extension TimePickerController: TimePickerViewDelegate {
    func getFromTimePicker(seconds: Int) {
        self.selectedSeconds = seconds
        print("getFromTimePicker \(selectedSeconds)")
    }
}

protocol TimePickerControllerDelegate: AnyObject {
    func get(selectedSeconds: Int)
    func deleteTimer()
}

