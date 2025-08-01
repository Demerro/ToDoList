//
//  TaskListInteractor.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import Foundation

protocol TaskListInteractorInput: AnyObject {
}

protocol TaskListInteractorOutput: AnyObject {
}

final class TaskListInteractor {
    
    weak var output: TaskListInteractorOutput? = nil
    
    let networkService: NetworkService
    let taskStorageService: TaskStorageService
    
    init(networkService: NetworkService, taskStorageService: TaskStorageService) {
        self.networkService = networkService
        self.taskStorageService = taskStorageService
    }
}

extension TaskListInteractor: TaskListInteractorInput {
}
