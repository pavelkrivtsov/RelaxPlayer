//
//  RelaxTimer.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 24.01.2023.
//

import Foundation

protocol RelaxTimerDelegate: AnyObject {
    func getRemainingSeconds(_ seconds: Int)
    func timerIsFinished()
}

class RelaxTimer {

    weak var delegate: RelaxTimerDelegate?
    private var timer: Timer?
    private var seconds = Int()

    @objc
    private func timerAction() {
        seconds -= 1
        delegate?.getRemainingSeconds(seconds)
        if seconds == 0 {
            delegate?.timerIsFinished()
            cancelTimer()
        }
    }
    
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
