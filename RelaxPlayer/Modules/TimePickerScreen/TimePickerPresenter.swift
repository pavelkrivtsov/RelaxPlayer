//
//  TimePickerPresenter.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 01.02.2023.
//

import Foundation

protocol TimePickerViewControllerOut: AnyObject {
    func setCountDownMode()
    func getFromTimePicker(selectedSeconds: Int)
    func togglePlayPause()
}

class TimePickerPresenter {
    
    weak var view: TimePickerViewControllerIn?
    private let timerManager: TimerManager
    
    private var isTimerActive = Bool()
    private var selectedSeconds = 60
//    private var remainingSeconds = Int()
    
    init(timerManager: TimerManager, isTimerActive: Bool) {
        self.timerManager = timerManager
        self.isTimerActive = isTimerActive
        self.timerManager.timePickerPresenter = self
    }
    
    deinit {
        print("TimePickerPresenter deinit")
    }
}

// MARK: - TimePickerViewControllerOut
extension TimePickerPresenter: TimePickerViewControllerOut {
    
    func getFromTimePicker(selectedSeconds: Int) {
        self.selectedSeconds = selectedSeconds
    }
    
    func togglePlayPause() {
        isTimerActive.toggle()

        if isTimerActive {
            timerManager.startTimer(with: selectedSeconds)
            setCountDownMode()
        } else {
            timerManager.cancelTimer()
            setCountDownMode()
        }
    }
    
    func setCountDownMode() {
        if isTimerActive {
            view?.prepareCountdownMode(with: selectedSeconds)
        } else {
            view?.stopCountdownMode()
        }
    }
}

// MARK: - TimerManagerOut
extension TimePickerPresenter: TimerManagerOut {
    
    func getRemainingSeconds(_ seconds: Int) {
//        remainingSeconds = seconds
        print("TimePickerPresenter \(seconds)")
        let currentValue = 1 - (Double(seconds) / Double(selectedSeconds))
        view?.startCountdownMode(seconds: seconds, value: currentValue)
    }
    
    func timerIsFinished() {
        isTimerActive.toggle()
        view?.stopCountdownMode()
    }
}
