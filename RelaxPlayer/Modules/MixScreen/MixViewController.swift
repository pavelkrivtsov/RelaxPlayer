//
//  MixViewController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.02.2023.
//

import UIKit
import CoreData

final class MixViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var fetchResultController: NSFetchedResultsController<Mix>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor")
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        let fetchRequest: NSFetchRequest = Mix.fetchRequest()
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: CoreDataStore.shared.context,
                                                           sectionNameKeyPath: nil,
                                                           cacheName:  nil)
        fetchResultController.delegate = self
        try! fetchResultController.performFetch()
        
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MixCell.self, forCellReuseIdentifier: MixCell.reuseId)
        tableView.separatorInset = .zero
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
    }
}

extension MixViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchResultController.fetchedObjects!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: MixCell.reuseId, for: indexPath) as? MixCell {
            let mix = fetchResultController.object(at: indexPath)
            cell.configure(mix: mix)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let mix = fetchResultController.object(at: indexPath)
            CoreDataStore.shared.context.delete(mix)
            CoreDataStore.shared.saveContext()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
}

extension MixViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .middle)
        default:
            break
        }
    }
}
