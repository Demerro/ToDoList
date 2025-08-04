//
//  TaskEntity.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 31.07.25.
//

import CoreData

final class TaskEntity: NSManagedObject {
    
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var taskDescription: String?
    @NSManaged var date: Date
    @NSManaged var isCompleted: Bool
    
    class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }
}

extension TaskEntity {
    
    enum Key: String {
        case id
        case title
        case taskDescription
        case date
        case isCompleted
    }
}
