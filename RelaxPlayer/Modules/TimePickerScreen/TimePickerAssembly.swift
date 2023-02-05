//
//  TimePickerAssembly.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 01.02.2023.
//

import UIKit

final class TimePickerAssembly {
    
    static func assemble(timerManager: TimerManager,
                         isTimerActive: Bool) -> UIViewController {
        
        let presenter = TimePickerPresenter(timerManager: timerManager,
                                            isTimerActive: isTimerActive)
        let view = TimePickerViewController(presenter: presenter)
        presenter.view = view
        return view
    }
}
