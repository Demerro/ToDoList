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
    private let backgroundContext: NSManagedObjectContext
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        self.backgroundContext = coreDataStack.makeBackgroundContext()
    }
}

extension TaskStorageService {
    
    func create(task: Task, completion: ((Error?) -> Void)? = nil) {
        let context = coreDataStack.makeBackgroundContext()
        context.perform { [weak self] in
            guard let coreDataStack = self?.coreDataStack else { return }
            let taskEntity = TaskEntity(context: context)
            taskEntity.id = task.id
            taskEntity.title = task.title
            taskEntity.taskDescription = task.description
            taskEntity.date = task.date
            taskEntity.isCompleted = task.isCompleted
            
            do {
                try coreDataStack.save(context: context)
                Logger.storage.info("Task created successfully: \(task.id)")
                completion?(nil)
            } catch {
                Logger.storage.error("Failed to create task: \(error)")
                completion?(Error.failedToCreateTask(error: error))
            }
        }
    }
    
    func create(tasks: [Task], completion: ((Error?) -> Void)? = nil) {
        guard !tasks.isEmpty else {
            completion?(nil)
            return
        }
        let context = coreDataStack.makeBackgroundContext()
        context.perform { [weak self] in
            guard let coreDataStack = self?.coreDataStack else { return }
            let dictionaries: [[String: Any]] = tasks.map { task in
                [
                    TaskEntity.Key.id.rawValue: task.id,
                    TaskEntity.Key.title.rawValue: task.title,
                    TaskEntity.Key.taskDescription.rawValue: task.description as Any,
                    TaskEntity.Key.date.rawValue: task.date,
                    TaskEntity.Key.isCompleted.rawValue: task.isCompleted
                ]
            }
            let batchInsertRequest = NSBatchInsertRequest(entity: TaskEntity.entity(), objects: dictionaries)
            do {
                try context.execute(batchInsertRequest)
                try coreDataStack.save(context: context)
                Logger.storage.info("Tasks created successfully.")
                completion?(nil)
            } catch {
                Logger.storage.error("Failed to create tasks: \(error)")
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
    
    func update(id: UUID, title: String, completion: ((Error?) -> Void)? = nil) {
        update(id: id) { taskEntity in
            taskEntity.title = title
        } completion: { error in
            completion?(error)
        }
    }
    
    func update(id: UUID, taskDescription: String?, completion: ((Error?) -> Void)? = nil) {
        update(id: id) { taskEntity in
            taskEntity.taskDescription = taskDescription
        } completion: { error in
            completion?(error)
        }
    }
    
    func update(id: UUID, date: Date, completion: ((Error?) -> Void)? = nil) {
        update(id: id) { taskEntity in
            taskEntity.date = date
        } completion: { error in
            completion?(error)
        }
    }
    
    func update(id: UUID, isCompleted: Bool, completion: ((Error?) -> Void)? = nil) {
        update(id: id) { taskEntity in
            taskEntity.isCompleted = isCompleted
        } completion: { error in
            completion?(error)
        }
    }
}

extension TaskStorageService {
    
    func delete(id: UUID, completion: ((Error?) -> Void)? = nil) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            do {
                let fetchRequest = Self.makeFetchRequest(id: id, includesPropertyValues: false)
                guard let taskEntity = try backgroundContext.fetch(fetchRequest).first else {
                    Logger.storage.error("Task with ID \(id) not found for deletion.")
                    completion?(Error.taskNotFound(id: id))
                    return
                }
                backgroundContext.delete(taskEntity)
                try coreDataStack.save(context: backgroundContext)
                Logger.storage.info("Task \(id) deleted successfully.")
                completion?(nil)
            } catch {
                Logger.storage.error("Failed to delete task \(id): \(error)")
                completion?(Error.failedToDeleteTask(id: id))
            }
        }
    }
}

extension TaskStorageService {
    
    private func update(id: UUID, updating: @escaping (TaskEntity) -> Void, completion: @escaping (Error?) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else { return }
            do {
                guard let taskEntity = try backgroundContext.fetch(Self.makeFetchRequest(id: id)).first else {
                    Logger.storage.error("Task with ID \(id) not found for update.")
                    completion(Error.taskNotFound(id: id))
                    return
                }
                updating(taskEntity)
                try coreDataStack.save(context: backgroundContext)
                Logger.storage.info("Task \(id) updated successfully.")
                completion(nil)
            } catch {
                Logger.storage.error("Failed to update task \(id): \(error)")
                completion(Error.failedToUpdateTask(id: id, error: error))
            }
        }
    }
    
    private static func makeFetchRequest(id: UUID, includesPropertyValues: Bool = true) -> NSFetchRequest<TaskEntity> {
        let fetchRequest = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.includesPropertyValues = includesPropertyValues
        return fetchRequest
    }
}

extension TaskStorageService {
    
    enum Error: Swift.Error {
        case taskNotFound(id: UUID)
        case failedToCreateTask(error: Swift.Error)
        case failedToFetchTasks(error: Swift.Error)
        case failedToUpdateTask(id: UUID, error: Swift.Error)
        case failedToDeleteTask(id: UUID)
    }
}
