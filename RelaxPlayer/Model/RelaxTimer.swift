//
//  RelaxTimer.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 05.03.2022.
//

import Foundation

protocol RelaxTimerDelegate: AnyObject {
    func get(remainingSeconds: Int, isTimerActive: Bool)
}

class RelaxTimer {
    
    var timer: Timer?
    var seconds = Int()
    var isTimerActive = false
    weak var delegate: RelaxTimerDelegate?
    
    func createTimer(with selectedSeconds: Int) {
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
        guard let timer = self.timer else { return }
        timer.tolerance = 0.1
        RunLoop.current.add(timer, forMode: .common)
        self.seconds = selectedSeconds
    }
    
    @objc private func timerAction() {
        seconds -= 1
        if seconds == 0 {
            cancelTimer()
        }
        isTimerActive = seconds == 0 ? false : true
        delegate?.get(remainingSeconds: seconds, isTimerActive: isTimerActive)
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
