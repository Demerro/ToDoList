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
    
    let router: AppRouterProtocol
    let view: TaskListPresenterToViewProtocol
    let interactor: TaskListPresenterToInteractorProtocol
    
    init(router: AppRouterProtocol, view: TaskListPresenterToViewProtocol, interactor: TaskListPresenterToInteractorProtocol) {
        self.router = router
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
        DispatchQueue.main.async {
            self.view.displayTasks(tasks)
        }
    }
    
    func didReceiveTaskEntities(_ entities: [TaskEntity]) {
        let tasks = entities.map {
            Task(id: $0.id, title: $0.title, isCompleted: $0.isCompleted, date: $0.date)
        }
        DispatchQueue.main.async {
            self.view.displayTasks(tasks)
        }
    }
    
    func didFailToReceiveTasks(with error: any Error) {
        DispatchQueue.main.async {
            self.router.showErrorAlert(title: "Oops! An error occurred.", message: error.localizedDescription)
        }
    }
}
