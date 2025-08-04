//
//  TaskListPresenter.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import Foundation

protocol TaskListPresenterToViewProtocol: AnyObject {
    func displayTasks(_ tasks: [Task])
    func reconfigureTask(_ task: Task)
}

protocol TaskListPresenterToInteractorProtocol: AnyObject {
    func getTasks()
}

final class TaskListPresenter {
    
    var interactor: TaskListPresenterToInteractorProtocol? = nil
    var view: TaskListPresenterToViewProtocol? = nil
    
    let router: AppRouterProtocol
    
    init(router: AppRouterProtocol) {
        self.router = router
    }
}

extension TaskListPresenter: TaskListViewToPresenterProtocol {
    
    func getTasks() {
        interactor?.getTasks()
    }
    
    func showEditTask(for task: Task) {
        router.showEditTask(task: task, delegate: self)
    }
}

extension TaskListPresenter: TaskListInteractorToPresenterProtocol {
    
    func didReceiveTasks(_ tasks: [Task]) {
        DispatchQueue.main.async {
            self.view?.displayTasks(tasks)
        }
    }
    
    func didReceiveTaskEntities(_ entities: [TaskEntity]) {
        let tasks = entities.map {
            Task(id: $0.id, title: $0.title, isCompleted: $0.isCompleted, date: $0.date, description: $0.taskDescription)
        }
        DispatchQueue.main.async {
            self.view?.displayTasks(tasks)
        }
    }
    
    func didFailToReceiveTasks(with error: any Error) {
        DispatchQueue.main.async {
            self.router.showErrorAlert(title: "Oops! An error occurred.", message: error.localizedDescription)
        }
    }
}

extension TaskListPresenter: EditTaskModuleDelegate {
    
    func editTaskModule(didUpdate task: Task) {
        DispatchQueue.main.async {
            self.view?.reconfigureTask(task)
        }
    }
}
