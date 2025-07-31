//
//  CoreDataStack.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 31.07.25.
//

import CoreData
import os.log

final class CoreDataStack {
    
    private static var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: CoreDataStack.self)
        guard let url = bundle.url(forResource: "Model", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url)
        else {
            fatalError("Failed to load managed object model.")
        }
        return model
    }()
    
    private let persistentContainer: NSPersistentContainer
    
    init(storeType: StoreType = .persisted) {
        persistentContainer = NSPersistentContainer(name: "Model", managedObjectModel: Self.managedObjectModel)
        if storeType == .inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
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
    
    func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
            Logger.storage.info("Context saved successfully.")
        } catch {
            context.rollback()
            Logger.storage.error("Failed to save context: \(error)")
            throw error
        }
    }
}

extension CoreDataStack {
    
    enum StoreType {
        case inMemory, persisted
    }
}
