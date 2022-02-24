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
    var remainingSeconds = 0
    weak var delegate: TimePickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .red
        
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
        timeLabel.text = String(remainingSeconds)
        
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
    
}


extension TimePickerView {
    
    func setDisplayMode(isTimerActive: Bool) {
        timePicker.isHidden = isTimerActive ? true : false
        timeLabel.isHidden = isTimerActive ? false : true
    }
    
    func makeTimeText(with seconds: Int)  {
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        
        if seconds < 3600 {
            timeLabel.text = NSString(format: "%0.2d:%0.2d", minutes, seconds) as String
        }
        timeLabel.text = NSString(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds) as String
    }
    
}

protocol TimePickerViewDelegate: AnyObject {
    func getFromTimePicker(seconds: Int)
}

