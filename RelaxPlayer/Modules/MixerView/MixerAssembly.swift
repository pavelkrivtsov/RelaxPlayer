//
//  MixerAssembly.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.01.2023.
//

import UIKit

class MixerASsembly {
    
    static func assemble(with noises: [String],
                         with noisesVolume: [String : Float],
                         mainPresenter: MainPresenterIn? = nil,
                         mianView: MainViewIn? = nil) -> UIViewController {
        
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        let tableManager = TableManager(tableView: tableView, noises: noises, noisesVolume: noisesVolume)
        let presenter = MixerPresenter(tableManager: tableManager)
        presenter.mainPresenter = mainPresenter
        tableManager.presenter = presenter
        let view = MixerView(presenter: presenter, tableView: tableView)
        view.mainView = mianView
        presenter.view = view
        return view
    }
}
