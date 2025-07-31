//
//  TaskStorageService.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 31.07.25.
//

import Foundation
import CoreData
import os.log

final class TaskStorageService {
    
    let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}

extension TaskStorageService {
    
    func create(title: String, taskDescription: String, date: Date, isCompleted: Bool) {
        let context = coreDataStack.makeBackgroundContext()
        context.perform { [weak coreDataStack] in
            guard let coreDataStack else { return }
            let taskEntity = TaskEntity(context: context)
            taskEntity.uuid = UUID()
            taskEntity.title = title
            taskEntity.taskDescription = taskDescription
            taskEntity.date = date
            taskEntity.isCompleted = isCompleted
            
            coreDataStack.save(context: context)
            Logger.storage.info("Task created successfully: \(title)")
        }
    }
}

extension TaskStorageService {
    
    func getAllTasks(_ completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        let context = coreDataStack.makeBackgroundContext()
        context.perform {
            let fetchRequest = TaskEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.date, ascending: false)]
            do {
                completion(.success(try context.fetch(fetchRequest)))
                Logger.storage.info("Successfully fetched tasks.")
            } catch {
                completion(.failure(error))
                Logger.storage.error("Failed to fetch tasks: \(error)")
            }
        }
    }
}

extension TaskStorageService {
    
    func update(uuid: UUID, title: String) {
        let context = coreDataStack.makeBackgroundContext()
        context.perform { [weak self] in
            guard let self else { return }
            if let taskEntity = try? context.fetch(self.makeFetchRequest(uuid: uuid)).first {
                taskEntity.title = title
                coreDataStack.save(context: context)
                Logger.storage.info("Task \(uuid) title updated to \(title).")
            } else {
                Logger.storage.error("Task with UUID \(uuid) not found for title update.")
            }
        }
    }
    
    func update(uuid: UUID, taskDescription: String) {
        let context = coreDataStack.makeBackgroundContext()
        context.perform { [weak self] in
            guard let self else { return }
            if let taskEntity = try? context.fetch(makeFetchRequest(uuid: uuid)).first {
                taskEntity.taskDescription = taskDescription
                coreDataStack.save(context: context)
                Logger.storage.info("Task \(uuid) description updated to \(taskDescription).")
            } else {
                Logger.storage.error("Task with UUID \(uuid) not found for description update.")
            }
        }
    }
    
    func update(uuid: UUID, date: Date) {
        let context = coreDataStack.makeBackgroundContext()
        context.perform { [weak self] in
            guard let self else { return }
            if let taskEntity = try? context.fetch(makeFetchRequest(uuid: uuid)).first {
                taskEntity.date = date
                coreDataStack.save(context: context)
                Logger.storage.info("Task \(uuid) date updated to \(date).")
            } else {
                Logger.storage.error("Task with UUID \(uuid) not found for date update.")
            }
        }
    }
    
    func update(uuid: UUID, isCompleted: Bool) {
        let context = coreDataStack.makeBackgroundContext()
        context.perform { [weak self] in
            guard let self else { return }
            if let taskEntity = try? context.fetch(makeFetchRequest(uuid: uuid)).first {
                taskEntity.isCompleted = isCompleted
                coreDataStack.save(context: context)
                Logger.storage.info("Task \(uuid) completion status updated to \(isCompleted).")
            } else {
                Logger.storage.error("Task with UUID \(uuid) not found for completion status update.")
            }
        }
    }
}

extension TaskStorageService {
    
    func delete(uuid: UUID) {
        let context = coreDataStack.makeBackgroundContext()
        context.perform { [weak self] in
            guard let self else { return }
            let fetchRequest = makeFetchRequest(uuid: uuid, includesPropertyValues: false)
            if let taskEntity = try? context.fetch(fetchRequest).first {
                context.delete(taskEntity)
                coreDataStack.save(context: context)
                Logger.storage.info("Task \(uuid) deleted successfully.")
            } else {
                Logger.storage.error("Task with UUID \(uuid) not found for deletion.")
            }
        }
    }
}

extension TaskStorageService {
    
    private func makeFetchRequest(uuid: UUID, includesPropertyValues: Bool = true) -> NSFetchRequest<TaskEntity> {
        let fetchRequest = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        fetchRequest.includesPropertyValues = includesPropertyValues
        return fetchRequest
    }
}
