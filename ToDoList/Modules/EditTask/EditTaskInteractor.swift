//
//  EditTaskInteractor.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 2.08.25.
//

import Foundation
import os.log

protocol EditTaskInteractorToPresenterProtocol: AnyObject {
    
    func didFailToUpdateTask(with error: Error)
}

final class EditTaskInteractor {
    
    unowned let presenter: EditTaskInteractorToPresenterProtocol
    let taskStorageService: TaskStorageService
    
    init(presenter: EditTaskInteractorToPresenterProtocol, taskStorageService: TaskStorageService) {
        self.presenter = presenter
        self.taskStorageService = taskStorageService
    }
}

extension EditTaskInteractor: EditTaskPresenterToInteractorProtocol {
    
    func saveTask(_ task: Task) {
        taskStorageService.update(id: task.id, taskDescription: task.description) { [weak presenter] error in
            if let error {
                Logger.editTask.error("Failed to update task: \(error)")
                presenter?.didFailToUpdateTask(with: error)
            } else {
                Logger.editTask.info("Task updated successfully: \(task.id)")
            }
        }
    }
}
