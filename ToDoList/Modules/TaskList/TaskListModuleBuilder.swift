//
//  TaskListModuleBuilder.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

struct TaskListModuleBuilder {
    
    static func build(dependencyContainer: AppDependencyContainer) -> UIViewController {
        let presenter = TaskListPresenter(router: dependencyContainer.appRouter)
        let view = TaskListViewController(presenter: presenter, dateFormatter: dependencyContainer.dateFormatter)
        let interactor = TaskListInteractor(
            presenter: presenter,
            networkService: dependencyContainer.networkService,
            taskStorageService: dependencyContainer.taskStorageService
        )
        
        presenter.interactor = interactor
        presenter.view = view
        
        return view
    }
}
