//
//  TaskListModuleBuilder.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

struct TaskListModuleBuilder {
    
    static func build(appRouter: AppRouterProtocol, networkService: NetworkService, taskStorageService: TaskStorageService) -> UIViewController {
        let presenter = TaskListPresenter(router: appRouter)
        let view = TaskListViewController(presenter: presenter)
        let interactor = TaskListInteractor(presenter: presenter, networkService: networkService, taskStorageService: taskStorageService)
        
        presenter.interactor = interactor
        presenter.view = view
        
        return view
    }
}
