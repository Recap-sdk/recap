//
//  Persistence.swift
//  Recap
//
//  Created by user@47 on 15/01/25.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    // The persistent container to manage Core Data
    let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "RecapModel") // Replace with your .xcdatamodeld file name
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // Save context method
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
