//
//  TimerManager.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 24.01.2023.
//

import Foundation

protocol TimerManagerIn: AnyObject {
    func startTimer(with seconds: Int)
    func cancelTimer()
}

class TimerManager: NSObject {
    
    weak var presenter: TimerManagerOut?
    private var timer: Timer?
    private var seconds = Int()
    
    @objc
    private func timerAction() {
        seconds -= 1
        presenter?.getRemainingSeconds(seconds)
        if seconds == 0 {
            presenter?.timerIsFinished()
            cancelTimer()
        }
    }
}

// MARK: - TimerManagerIn
extension TimerManager: TimerManagerIn {
    
    func startTimer(with seconds: Int) {
        timer = Timer(timeInterval: 1,
                      target: self,
                      selector: #selector(timerAction),
                      userInfo: nil,
                      repeats: true)
        self.seconds = seconds
        guard let timer = timer else { return }
        timer.tolerance = 0.1
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
}
