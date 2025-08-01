//
//  AppRouter.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

final class AppRouter {
    
    let navigationController = UINavigationController()
    private let dependencies: AppDependencyContainer

    init(dependencies: AppDependencyContainer) {
        self.dependencies = dependencies
    }

    func showTaskList() {
        let module = TaskListModuleBuilder.build(networkService: dependencies.networkService, taskStorageService: dependencies.taskStorageService)
        navigationController.setViewControllers([module], animated: false)
    }
}
