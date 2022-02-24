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
    
    var label = UILabel()
    
    weak var delegate: TimePickerControllerDelegate?
    let main = MainViewController()
    
    
    //  MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = "Timer"
        
        timePickerView.setDisplayMode(isTimerActive: false)
        setupTimePicker()
        setupLabel()
        setupPlayPauseButton()
    }
    
    func setupTimePicker() {
        view.addSubview(timePickerView)
        NSLayoutConstraint.activate([
            timePickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timePickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        timePickerView.delegate = self
    }
    
    func setupLabel() {
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: timePickerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: timePickerView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: timePickerView.topAnchor),
            label.heightAnchor.constraint(equalToConstant: 50)
        ])
        label.backgroundColor = .yellow
        label.text = "text"
    }
    
    func setupPlayPauseButton() {
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
            timePickerView.setDisplayMode(isTimerActive: true)
        } else {
            timePickerView.setDisplayMode(isTimerActive: false)
            delegate?.deleteTimer()
        }
        playPauseButton.configuration?.image = UIImage(systemName: isTimerActive ? "stop" : "play")
    }

}


//  MARK: - TimePickerViewDelegate
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

