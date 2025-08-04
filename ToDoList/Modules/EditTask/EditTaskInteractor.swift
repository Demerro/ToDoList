//
//  EditTaskInteractor.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 2.08.25.
//

import Foundation
import os.log

protocol EditTaskInteractorToPresenterProtocol: AnyObject {
}

final class EditTaskInteractor {
    
    var presenter: EditTaskInteractorToPresenterProtocol? = nil
    
    let taskStorageService: TaskStorageService
    
    init(taskStorageService: TaskStorageService) {
        self.taskStorageService = taskStorageService
    }
}

extension EditTaskInteractor: EditTaskPresenterToInteractorProtocol {
    
    func saveTask(_ task: Task) {
        taskStorageService.update(id: task.id, taskDescription: task.description) { error in
            if let error {
                Logger.editTask.error("Failed to update task: \(error)")
            } else {
                Logger.editTask.info("Task updated successfully: \(task.id)")
            }
        }
    }
}
