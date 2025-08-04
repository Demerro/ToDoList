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
    func deleteTask(with id: Int)
}

protocol TaskListPresenterToInteractorProtocol: AnyObject {
    func getTasks()
    func deleteTask(_ task: Task)
    func completeTask(_ task: Task)
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
    
    func deleteTask(_ task: Task) {
        interactor?.deleteTask(task)
    }
    
    func shareTask(_ task: Task) {
        router.showActivityViewController(for: task)
    }
    
    func completeTask(_ task: Task) {
        interactor?.completeTask(task)
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
    
    func didFail(with error: any Error) {
        DispatchQueue.main.async {
            self.router.showErrorAlert(title: "Oops! An error occurred.", message: error.localizedDescription)
        }
    }
    
    func didDeleteTask(with id: Int) {
        DispatchQueue.main.async {
            self.view?.deleteTask(with: id)
        }
    }
    
    func didCompleteTask(_ task: Task) {
        DispatchQueue.main.async {
            self.view?.reconfigureTask(task)
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
