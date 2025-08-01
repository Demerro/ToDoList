//
//  TaskListPresenter.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import Foundation

protocol TaskListPresenterToViewProtocol: AnyObject {
    func displayTasks(_ tasks: [Task])
}

protocol TaskListPresenterToInteractorProtocol: AnyObject {
    func getTasks()
}

final class TaskListPresenter {
    
    let view: TaskListPresenterToViewProtocol
    let interactor: TaskListPresenterToInteractorProtocol
    
    init(view: TaskListPresenterToViewProtocol, interactor: TaskListPresenterToInteractorProtocol) {
        self.view = view
        self.interactor = interactor
    }
}

extension TaskListPresenter: TaskListViewToPresenterProtocol {
    
    func getTasks() {
        interactor.getTasks()
    }
}

extension TaskListPresenter: TaskListInteractorToPresenterProtocol {
    
    func didReceiveDTOs(_ taskDTOs: [TaskDTO]) {
        let tasks = taskDTOs.map {
            Task(id: $0.id, title: $0.todo, isCompleted: $0.completed, date: Date())
        }
        view.displayTasks(tasks)
    }
    
    func didReceiveTaskEntities(_ entities: [TaskEntity]) {
        let tasks = entities.map {
            Task(id: $0.id, title: $0.title, isCompleted: $0.isCompleted, date: $0.date)
        }
        view.displayTasks(tasks)
    }
    
    func didFailToReceiveTasks(with error: any Error) {
        
    }
}
