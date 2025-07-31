//
//  CoreDataStack.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 31.07.25.
//

import CoreData
import os.log

final class CoreDataStack {
    
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                Logger.storage.error("Failed to load persistent stores: \(error)")
            }
        }
    }
}

extension CoreDataStack {
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func makeBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
}

extension CoreDataStack {
    
    func save(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
            Logger.storage.info("Context saved successfully.")
        } catch {
            context.rollback()
            Logger.storage.error("Failed to save context: \(error)")
        }
    }
}
