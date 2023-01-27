//
//  MixerAssembly.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.01.2023.
//

import UIKit

class MixerAssembly {
    
    static func assemble(players: [String],
                         playersVolume: [String : Float],
                         presenter: MixerViewControllerOut) -> UIViewController {
        
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        let tableManager = TableManager(tableView: tableView, players: players, playersVolume: playersVolume)
        let view = MixerViewController(tableManager: tableManager, tableView: tableView)
        view.presenter = presenter
        tableManager.view = view
        return view
    }
}
