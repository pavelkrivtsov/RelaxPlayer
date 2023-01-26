//
//  TimePicker.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 21.02.2022.
//

import UIKit

protocol TimePickerViewOut: AnyObject {
    func getFromTimePicker(selectedSeconds: Int)
}

class TimePickerView: UIView {
    
    weak var view: TimePickerViewOut?
    private var timePicker = UIDatePicker()
    private var timeLabel = UILabel()
//    private var foregroundShapeLayer = CAShapeLayer()
//    private var backgroundShapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        setupTimePicker()
        setupTimeLabel()
//        createBackgroundShapeLayer()
//        createForegroundShapeLayer()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTimePicker() {
        self.addSubview(timePicker)
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timePicker.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            timePicker.topAnchor.constraint(equalTo: self.topAnchor),
            timePicker.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        timePicker.datePickerMode = .countDownTimer
        timePicker.addTarget(self, action: #selector(setNewValue), for: .valueChanged)
    }
    
    private func setupTimeLabel() {
        self.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            timeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        timeLabel.textAlignment = .center
        timeLabel.font = .systemFont(ofSize: 35)
    }
    
    @objc
    private func setNewValue() {
        let seconds = Int(timePicker.countDownDuration)
        view?.getFromTimePicker(selectedSeconds: seconds)
    }
    
    private func makeTimeText(with remainingSeconds: Int) -> String  {
        let hours = remainingSeconds / 3600
        let minutes = remainingSeconds / 60 % 60
        let seconds = remainingSeconds % 60
        
        if remainingSeconds < 3600 {
            return NSString(format: "%0.2d:%0.2d", minutes, seconds) as String
        }
        return NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
    }
    
//    private func createForegroundShapeLayer() {
//        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
//        let radius = frame.width / 2 - foregroundShapeLayer.lineWidth / 2
//        let startAngle = 3 * CGFloat.pi / 2
//        let endAngle = 2 * -CGFloat.pi + startAngle
//        let circlePath = UIBezierPath(arcCenter: center,
//                                      radius: radius,
//                                      startAngle: startAngle,
//                                      endAngle: endAngle,
//                                      clockwise: false)
//        foregroundShapeLayer.path = circlePath.cgPath
//        foregroundShapeLayer.lineWidth = 30
//        foregroundShapeLayer.fillColor = UIColor.clear.cgColor
//        foregroundShapeLayer.lineCap = CAShapeLayerLineCap.round
//        foregroundShapeLayer.strokeColor = UIColor.orange.cgColor
//        layer.addSublayer(foregroundShapeLayer)
//    }
    
//    private func createBackgroundShapeLayer() {
//        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
//        let radius = frame.width / 2 - foregroundShapeLayer.lineWidth / 2
//        let startAngle = 3 * CGFloat.pi / 2
//        let endAngle = 2 * -CGFloat.pi + startAngle
//        let circlePath = UIBezierPath(arcCenter: center,
//                                      radius: radius,
//                                      startAngle: startAngle,
//                                      endAngle: endAngle,
//                                      clockwise: false)
//        backgroundShapeLayer.path = circlePath.cgPath
//        backgroundShapeLayer.lineWidth = 30
//        backgroundShapeLayer.fillColor = UIColor.clear.cgColor
//        backgroundShapeLayer.lineCap = CAShapeLayerLineCap.round
//        backgroundShapeLayer.strokeColor = UIColor.systemGray2.cgColor
//        layer.addSublayer(backgroundShapeLayer)
//    }
}

extension TimePickerView {

    func startCountdownMode(with seconds: Int) {
        timeLabel.text = makeTimeText(with: seconds)
    
    }
    
    func prepareCountdownMode(with seconds: Int) {
        timePicker.isHidden = true
        timeLabel.isHidden = false
        timeLabel.text = makeTimeText(with: seconds)
        
    }

    func stopCountdownMode() {
        timePicker.isHidden = false
        timeLabel.isHidden = true
    }
    
    
    //    func setDisplayMode(isTimerActive: Bool) {
    //        timePicker.isHidden = isTimerActive ? true : false
    //        timeLabel.isHidden = isTimerActive ? false : true
    //        foregroundShapeLayer.isHidden = isTimerActive ? false : true
    //        backgroundShapeLayer.isHidden = isTimerActive ? false : true
    //    }
    
//    func setLastSelectedTime(from seconds: Int) {
//        let hours = seconds / 3600
//        let minutes = seconds / 60 % 60
//        let seconds = seconds % 60
//
//        let dateComp : NSDateComponents = NSDateComponents()
//        dateComp.hour = hours
//        dateComp.minute = minutes
//        dateComp.second = seconds
//        let calendar : NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
//        let date : NSDate = calendar.date(from: dateComp as DateComponents)! as NSDate
//        timePicker.setDate(date as Date, animated: false)
//    }
    
//    func startAnimation(by value: Double, with selectedSeconds: Int) {
//        let basicAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
//        basicAnimation.toValue = 1
//        basicAnimation.fromValue = value
//        basicAnimation.duration = CFTimeInterval(selectedSeconds)
//        foregroundShapeLayer.add(basicAnimation, forKey: nil)
//    }
//
//    func startAnimation(with selectedSeconds: Int) {
//        let basicAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
//        basicAnimation.toValue = 1
//        basicAnimation.fromValue = 0
//        basicAnimation.duration = CFTimeInterval(selectedSeconds)
//        foregroundShapeLayer.add(basicAnimation, forKey: nil)
//    }
}
