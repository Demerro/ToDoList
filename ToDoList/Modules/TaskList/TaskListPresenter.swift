//
//  TaskListPresenter.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import Foundation

final class TaskListPresenter {
    
    unowned let view: TaskListViewInput
    let interactor: TaskListInteractorInput
    
    init(view: TaskListViewInput, interactor: TaskListInteractorInput) {
        self.view = view
        self.interactor = interactor
    }
}

extension TaskListPresenter: TaskListViewOutput {
}

extension TaskListPresenter: TaskListInteractorOutput {
}
