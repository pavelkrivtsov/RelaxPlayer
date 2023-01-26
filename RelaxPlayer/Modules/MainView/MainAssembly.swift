//
//  MainAssembly.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 13.01.2023.
//

import UIKit

class MainAssembly {
    
    static func assemble() -> UIViewController {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        let collectionManager = CollectionManager(collectionView: collectionView)
        let timerManager = TimerManager()
        let presenter = MainPresenter(collectionManager: collectionManager, timerManager: timerManager)
        timerManager.presenter = presenter
        collectionManager.presenter = presenter
        let view = MainViewController(presenter: presenter, collectionView: collectionView)
        presenter.view = view
        return view
    }
}
