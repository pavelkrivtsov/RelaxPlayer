//
//  TimePickerController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 30.12.2021.
//

import UIKit

class TimePickerController: UIViewController {
    
    //  MARK: - declaring variables
    var timePicker = UIDatePicker()
    var timeLabel = UILabel()
    var circleImageView = UIImageView()
    var circleShapeLayer = CAShapeLayer()
    var playPauseButton = UIButton()
    var timer: Timer?
    var isTimerStarted = false
    var selectedTimeNumber = 0
    var counter = 0
    var counterOnCompletion: ((Int) -> ())?
    var isTimerStartedOnCompletion: ((Bool) -> ())?
    
    //  MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = "Timer"
        setupTimePicker()
        setupPlayPauseButton()
        setupTimeLabel()
        setupСircleImageView()
    }
    
    //      MARK: - view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        controllerDisplayMode()
        timeLabelDisplayMode(accordingToThe: counter)
        if isTimerStarted {
            let currentValue = 1 - (Double(counter) / Double(selectedTimeNumber))
            startAnimation(by: currentValue)
        }
    }
    
    //  MARK: - view did layout subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.createCircleShape()
    }
    
    //  MARK: - setup timer picker
    func setupTimePicker() {
        view.addSubview(timePicker)
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timePicker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
            timePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            timePicker.heightAnchor.constraint(equalTo: timePicker.widthAnchor)
        ])
        timePicker.datePickerMode = .countDownTimer
    }
    
    //  MARK: - setup image view
    func setupСircleImageView() {
        view.addSubview(circleImageView)
        circleImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            circleImageView.centerXAnchor.constraint(equalTo: timePicker.centerXAnchor),
            circleImageView.centerYAnchor.constraint(equalTo: timePicker.centerYAnchor),
            circleImageView.widthAnchor.constraint(equalTo: timePicker.widthAnchor),
            circleImageView.heightAnchor.constraint(equalTo: timePicker.heightAnchor)
        ])
        circleImageView.image = UIImage(named: "circle")
        circleImageView.isHidden = true
    }
    
    //  MARK: - setup time label
    func setupTimeLabel() {
        circleImageView.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: circleImageView.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: circleImageView.centerYAnchor)
        ])
        timeLabel.textAlignment = .center
        timeLabel.font = .systemFont(ofSize: 35)
    }
    
    //  MARK: - setup play/pause button
    func setupPlayPauseButton() {
        view.addSubview(playPauseButton)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: timePicker.centerXAnchor),
            playPauseButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 20),
        ])
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        configuration.image = UIImage(systemName: "play")
        configuration.buttonSize = .large
        configuration.cornerStyle = .capsule
        playPauseButton.configuration = configuration
        playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed), for: .touchUpInside)
    }
    
    @objc func playPauseButtonPressed() {
        isTimerStarted.toggle()
        controllerDisplayMode()
        
        if isTimerStarted {
            counter = Int(timePicker.countDownDuration)
            counterOnCompletion?(counter)
            timeLabelDisplayMode(accordingToThe: counter)
            startAnimation(by: 0)
        } else {
            timer?.invalidate()
            timer = nil
            isTimerStartedOnCompletion?(false)
        }
    }
    
    //  MARK: - controller display mode
    func controllerDisplayMode() {
        timeLabel.isHidden = isTimerStarted ? false : true
        circleImageView.isHidden = isTimerStarted ? false : true
        timePicker.isHidden = isTimerStarted ? true : false
        playPauseButton.setImage(UIImage(systemName: isTimerStarted ? "stop" : "play"), for: .normal)
    }
    
    //  MARK: - time label display mode
    func timeLabelDisplayMode(accordingToThe counter: Int) {
        let hours = counter / 3600
        let minutes = counter / 60 % 60
        let seconds = counter % 60
        
        if counter < 3600 {
            timeLabel.text = NSString(format: "%0.2d:%0.2d", minutes, seconds) as String
        } else {
            timeLabel.text = NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
        }
    }
    
    //  MARK: - animation
    func createCircleShape() {
        let center = CGPoint(x: circleImageView.frame.width / 2, y: circleImageView.frame.height / 2)
        let radius = circleImageView.frame.width / 2 - circleShapeLayer.lineWidth / 2
        let startAngle = 3 * CGFloat.pi / 2
        let endAngle = 2 * -CGFloat.pi + startAngle
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: startAngle,
                                      endAngle: endAngle,
                                      clockwise: false)
        circleShapeLayer.path = circlePath.cgPath
        circleShapeLayer.lineWidth = 29
        circleShapeLayer.fillColor = UIColor.clear.cgColor
        circleShapeLayer.lineCap = CAShapeLayerLineCap.round
        circleShapeLayer.strokeColor = UIColor.orange.cgColor
        circleImageView.layer.addSublayer(circleShapeLayer)
    }
    
    func startAnimation(by value: Double) {
        let basicAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
        basicAnimation.toValue = 1
        basicAnimation.fromValue = value
        basicAnimation.duration = CFTimeInterval(counter)
        circleShapeLayer.add(basicAnimation, forKey: nil)
    }
}
