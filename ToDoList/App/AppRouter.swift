//
//  AppRouter.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

protocol AppRouterProtocol: AnyObject {
    func showErrorAlert(title: String, message: String)
    func showTaskList()
    func showEditTask(task: Task, delegate: EditTaskModuleDelegate?)
    func showActivityViewController(for task: Task)
}

final class AppRouter {
    
    let navigationController = UINavigationController()
    private let dependencies: AppDependencyContainer

    init(dependencies: AppDependencyContainer) {
        self.dependencies = dependencies
        navigationController.navigationBar.prefersLargeTitles = true
    }
}

extension AppRouter: AppRouterProtocol {
    
    func showErrorAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        navigationController.present(alertViewController, animated: true)
    }
    
    func showTaskList() {
        let module = TaskListModuleBuilder.build(appRouter: self, networkService: dependencies.networkService, taskStorageService: dependencies.taskStorageService)
        navigationController.setViewControllers([module], animated: false)
    }
    
    func showEditTask(task: Task, delegate: EditTaskModuleDelegate?) {
        let module = EditTaskModuleBuilder.build(task: task, appRouter: self, taskStorageService: dependencies.taskStorageService, delegate: delegate)
        navigationController.pushViewController(module, animated: true)
    }
    
    func showActivityViewController(for task: Task) {
        var items = [task.title]
        if let description = task.description {
            items.append(description)
        }
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        navigationController.present(activityViewController, animated: true)
    }
}
