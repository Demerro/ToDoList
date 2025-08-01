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
    let backgroundContext: NSManagedObjectContext
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        self.backgroundContext = coreDataStack.makeBackgroundContext()
    }
}

extension TaskStorageService {
    
    func create(id: Int, title: String, taskDescription: String, date: Date, isCompleted: Bool, completion: ((Error?) -> Void)? = nil) {
        let context = coreDataStack.makeBackgroundContext()
        context.perform { [weak coreDataStack] in
            guard let coreDataStack else { return }
            let taskEntity = TaskEntity(context: context)
            taskEntity.id = id
            taskEntity.title = title
            taskEntity.taskDescription = taskDescription
            taskEntity.date = date
            taskEntity.isCompleted = isCompleted
            
            do {
                try coreDataStack.save(context: context)
                Logger.storage.info("Task created successfully: \(title)")
            } catch {
                Logger.storage.error("Failed to create task: \(error)")
                completion?(Error.failedToCreateTask(error: error))
            }
        }
    }
}

extension TaskStorageService {
    
    func getAllTasks(_ completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            let fetchRequest = TaskEntity.fetchRequest()
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.date, ascending: false)]
            do {
                Logger.storage.info("Successfully fetched tasks.")
                completion(.success(try backgroundContext.fetch(fetchRequest)))
            } catch {
                Logger.storage.error("Failed to fetch tasks: \(error)")
                completion(.failure(Error.failedToFetchTasks(error: error)))
            }
        }
    }
}

extension TaskStorageService {
    
    func update(uuid: UUID, title: String, completion: ((Error?) -> Void)? = nil) {
        update(uuid: uuid) { taskEntity in
            taskEntity.title = title
        } completion: { error in
            completion?(error)
        }
    }
    
    func update(uuid: UUID, taskDescription: String, completion: ((Error?) -> Void)? = nil) {
        update(uuid: uuid) { taskEntity in
            taskEntity.taskDescription = taskDescription
        } completion: { error in
            completion?(error)
        }
    }
    
    func update(uuid: UUID, date: Date, completion: ((Error?) -> Void)? = nil) {
        update(uuid: uuid) { taskEntity in
            taskEntity.date = date
        } completion: { error in
            completion?(error)
        }
    }
    
    func update(uuid: UUID, isCompleted: Bool, completion: ((Error?) -> Void)? = nil) {
        update(uuid: uuid) { taskEntity in
            taskEntity.isCompleted = isCompleted
        } completion: { error in
            completion?(error)
        }
    }
    
    private func update(uuid: UUID, updating: @escaping (TaskEntity) -> Void, completion: @escaping (Error?) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            do {
                guard let taskEntity = try backgroundContext.fetch(Self.makeFetchRequest(uuid: uuid)).first else {
                    Logger.storage.error("Task with UUID \(uuid) not found for update.")
                    completion(Error.taskNotFound(uuid: uuid))
                    return
                }
                updating(taskEntity)
                try coreDataStack.save(context: backgroundContext)
                Logger.storage.info("Task \(uuid) updated successfully.")
                completion(nil)
            } catch {
                Logger.storage.error("Failed to update task \(uuid): \(error)")
                completion(Error.failedToUpdateTask(uuid: uuid, error: error))
            }
        }
    }
}

extension TaskStorageService {
    
    func delete(uuid: UUID, completion: ((Error?) -> Void)? = nil) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            do {
                let fetchRequest = Self.makeFetchRequest(uuid: uuid, includesPropertyValues: false)
                guard let taskEntity = try backgroundContext.fetch(fetchRequest).first else {
                    Logger.storage.error("Task with UUID \(uuid) not found for deletion.")
                    completion?(Error.taskNotFound(uuid: uuid))
                    return
                }
                backgroundContext.delete(taskEntity)
                try coreDataStack.save(context: backgroundContext)
                Logger.storage.info("Task \(uuid) deleted successfully.")
                completion?(nil)
            } catch {
                Logger.storage.error("Failed to delete task \(uuid): \(error)")
                completion?(Error.failedToDeleteTask(uuid: uuid))
            }
        }
    }
}

extension TaskStorageService {
    
    private static func makeFetchRequest(uuid: UUID, includesPropertyValues: Bool = true) -> NSFetchRequest<TaskEntity> {
        let fetchRequest = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        fetchRequest.includesPropertyValues = includesPropertyValues
        return fetchRequest
    }
}

extension TaskStorageService {
    
    enum Error: Swift.Error {
        case taskNotFound(uuid: UUID)
        case failedToCreateTask(error: Swift.Error)
        case failedToFetchTasks(error: Swift.Error)
        case failedToUpdateTask(uuid: UUID, error: Swift.Error)
        case failedToDeleteTask(uuid: UUID)
    }
}
