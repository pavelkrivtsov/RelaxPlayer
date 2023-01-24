//
//  MixerAssembly.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.01.2023.
//

import UIKit

class MixerAssembly {
    
    static func assemble(noises: [String],
                         noisesVolume: [String : Float],
                         mianView: MainVСIn? = nil) -> UIViewController {
        
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        let tableManager = TableManager(tableView: tableView, noises: noises, noisesVolume: noisesVolume)
        let presenter = MixerPresenter(tableManager: tableManager)
        tableManager.presenter = presenter
        let view = MixerVС(presenter: presenter, tableView: tableView)
        view.mainView = mianView
        presenter.view = view
        return view
    }
}
