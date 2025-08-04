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
    func showTextFieldAlert(
        title: String,
        destructiveActionTitle: String,
        defaultActionTitle: String,
        errorTitle: String,
        errorMessage: String,
        completion: @escaping (String) -> Void
    )
}

final class AppRouter {
    
    let navigationController = UINavigationController()
    private let dependencies: AppDependencyContainer

    init(dependencies: AppDependencyContainer) {
        self.dependencies = dependencies
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.isToolbarHidden = false
    }
}

extension AppRouter: AppRouterProtocol {
    
    func showErrorAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default))
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
    
    func showTextFieldAlert(
        title: String,
        destructiveActionTitle: String,
        defaultActionTitle: String,
        errorTitle: String,
        errorMessage: String,
        completion: @escaping (String) -> Void
    ) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addTextField()
        alertController.addAction(UIAlertAction(title: destructiveActionTitle, style: .destructive))
        alertController.addAction(UIAlertAction(title: defaultActionTitle, style: .default, handler: { [unowned self] _ in
            if let text = alertController.textFields?.first?.text, !text.isEmpty {
                completion(text)
            } else {
                showErrorAlert(title: errorTitle, message: destructiveActionTitle)
            }
        }))
        navigationController.present(alertController, animated: true)
    }
}
