//
//  CoreDataStore.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 17.02.2023.
//

import Foundation
import CoreData


final class CoreDataStore {
    
    static var shared = CoreDataStore()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var context = persistentContainer.viewContext

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveMix(name: String) {
        let mix = Mix(context: context)
        mix.name = name
        mix.id = UUID()
        mix.createdAt = Date()
        saveContext()
    }
}
