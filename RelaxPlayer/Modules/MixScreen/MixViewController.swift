//
//  MixViewController.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.02.2023.
//

import UIKit
import CoreData

protocol MixViewControllerDelegate: AnyObject {
    func setMix(noises: [Noise])
}

final class MixViewController: UIViewController {
    
    weak var delegate: MixViewControllerDelegate?
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var fetchResultController = NSFetchedResultsController<Mix>()
    private var impactGenerator = UIImpactFeedbackGenerator(style: .rigid)
    
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
        do {
            try fetchResultController.performFetch()
        } catch let error {
            print(error.localizedDescription)
        }
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MixCell.self, forCellReuseIdentifier: MixCell.reuseId)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
}

// MARK: - UITableViewDataSource
extension MixViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchedObjects = fetchResultController.fetchedObjects else { return 0 }
        return fetchedObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: MixCell.reuseId, for: indexPath) as? MixCell {
            let mix = fetchResultController.object(at: indexPath)
            cell.configure(mix: mix)
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension MixViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mix = fetchResultController.object(at: indexPath)
        guard let noises = mix.noises.allObjects as? [Noise] else {
            return print("error configure cell")
        }
        
        print("noises \(noises)")
        delegate?.setMix(noises: noises)
        impactGenerator.impactOccurred()
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            let mix = fetchResultController.object(at: indexPath)
            CoreDataStore.shared.context.delete(mix)
            CoreDataStore.shared.saveContext()
        default:
            break
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
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
