//
//  TimePicker.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 21.02.2022.
//

import UIKit

class TimePickerView: UIView {
    
    var timePicker = UIDatePicker()
    var timeLabel = UILabel()
    var foregroundShapeLayer = CAShapeLayer()
    var backgroundShapeLayer = CAShapeLayer()
    weak var delegate: TimePickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(timePicker)
        NSLayoutConstraint.activate([
            timePicker.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            timePicker.topAnchor.constraint(equalTo: self.topAnchor),
            timePicker.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.datePickerMode = .countDownTimer
        let dateComp : NSDateComponents = NSDateComponents()
        dateComp.hour = 0
        dateComp.minute = 1
        let calendar : NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let date : NSDate = calendar.date(from: dateComp as DateComponents)! as NSDate
        timePicker.setDate(date as Date, animated: true)
        timePicker.addTarget(self, action: #selector(setNewValue), for: .valueChanged)
        
        self.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            timeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = .center
        timeLabel.font = .systemFont(ofSize: 35)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setNewValue() {
        let seconds = Int(timePicker.countDownDuration)
        delegate?.getFromTimePicker(seconds: seconds)
    }
    
    func createForegroundShapeLayer() {
        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let radius = frame.width / 2 - foregroundShapeLayer.lineWidth / 2
        let startAngle = 3 * CGFloat.pi / 2
        let endAngle = 2 * -CGFloat.pi + startAngle
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: startAngle,
                                      endAngle: endAngle,
                                      clockwise: false)
        foregroundShapeLayer.path = circlePath.cgPath
        foregroundShapeLayer.lineWidth = 30
        foregroundShapeLayer.fillColor = UIColor.clear.cgColor
        foregroundShapeLayer.lineCap = CAShapeLayerLineCap.round
        foregroundShapeLayer.strokeColor = UIColor.orange.cgColor
        layer.addSublayer(foregroundShapeLayer)
    }
    
    func createBackgroundShapeLayer() {
        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let radius = frame.width / 2 - foregroundShapeLayer.lineWidth / 2
        let startAngle = 3 * CGFloat.pi / 2
        let endAngle = 2 * -CGFloat.pi + startAngle
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: startAngle,
                                      endAngle: endAngle,
                                      clockwise: false)
        backgroundShapeLayer.path = circlePath.cgPath
        backgroundShapeLayer.lineWidth = 30
        backgroundShapeLayer.fillColor = UIColor.clear.cgColor
        backgroundShapeLayer.lineCap = CAShapeLayerLineCap.round
        backgroundShapeLayer.strokeColor = UIColor.systemGray2.cgColor
        layer.addSublayer(backgroundShapeLayer)
    }
    
}


extension TimePickerView {
    
    func setDisplayMode(isTimerActive: Bool) {
        timePicker.isHidden = isTimerActive ? true : false
        timeLabel.isHidden = isTimerActive ? false : true
        foregroundShapeLayer.isHidden = isTimerActive ? false : true
        backgroundShapeLayer.isHidden = isTimerActive ? false : true
    }
    
    func setTimeLabelText(with seconds: Int) {
        timeLabel.text = makeTimeText(with: seconds)
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
    
    func setLastSelectedTime(from seconds: Int) {
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        
        let dateComp : NSDateComponents = NSDateComponents()
        dateComp.hour = hours
        dateComp.minute = minutes
        dateComp.second = seconds
        let calendar : NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let date : NSDate = calendar.date(from: dateComp as DateComponents)! as NSDate
        timePicker.setDate(date as Date, animated: false)
    }
    
    func startAnimation(by value: Double, with selectedSeconds: Int) {
        let basicAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
        basicAnimation.toValue = 1
        basicAnimation.fromValue = value
        basicAnimation.duration = CFTimeInterval(selectedSeconds)
        foregroundShapeLayer.add(basicAnimation, forKey: nil)
    }
    
    func startAnimation(with selectedSeconds: Int) {
        let basicAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
        basicAnimation.toValue = 1
        basicAnimation.fromValue = 0
        basicAnimation.duration = CFTimeInterval(selectedSeconds)
        foregroundShapeLayer.add(basicAnimation, forKey: nil)
    }
    
}

protocol TimePickerViewDelegate: AnyObject {
    func getFromTimePicker(seconds: Int)
}

