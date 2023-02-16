//
//  Timer.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 24.01.2023.
//

import Foundation

protocol TimerDelegate: AnyObject {
    func getRemainingSeconds(_ seconds: Int)
    func timerIsFinished()
}

final class Timer {
    
    weak var delegate: TimerDelegate?
    private var timer: DispatchSourceTimer?
    private var seconds = Int()
    
    func start(with seconds: Int) {
        self.seconds = seconds + 1
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: 1)
        timer?.setEventHandler { [weak self] in
            guard let `self` = self else { return }
            self.seconds -= 1
            DispatchQueue.main.async {
                self.delegate?.getRemainingSeconds(self.seconds)
                print(self.seconds)
            }
            
            if self.seconds == 0 {
                self.timer = nil
                DispatchQueue.main.async {
                    self.delegate?.timerIsFinished()
                }
            }
        }
        timer?.resume()
    }
    
    func stop() {
        timer = nil
    }
}
