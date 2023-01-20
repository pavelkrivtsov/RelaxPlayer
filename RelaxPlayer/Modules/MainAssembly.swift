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
        let presenter = MainPresenter(collectionManager: collectionManager)
        collectionManager.presenter = presenter
        let view = MainView(presenter: presenter, collectionView: collectionView)
        presenter.view = view
        return view
    }
}
