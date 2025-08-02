//
//  AppRouter.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

protocol AppRouterProtocol: AnyObject {
    func showErrorAlert(title: String, message: String)
}

final class AppRouter {
    
    let navigationController = UINavigationController()
    private let dependencies: AppDependencyContainer

    init(dependencies: AppDependencyContainer) {
        self.dependencies = dependencies
    }

    func showTaskList() {
        let module = TaskListModuleBuilder.build(appRouter: self, networkService: dependencies.networkService, taskStorageService: dependencies.taskStorageService)
        navigationController.setViewControllers([module], animated: false)
    }
}

extension AppRouter: AppRouterProtocol {
    
    func showErrorAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        navigationController.present(alertViewController, animated: true)
    }
}
