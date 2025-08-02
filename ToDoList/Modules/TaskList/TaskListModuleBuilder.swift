//
//  TaskListModuleBuilder.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

struct TaskListModuleBuilder {
    
    static func build(appRouter: AppRouterProtocol, networkService: NetworkService, taskStorageService: TaskStorageService) -> UIViewController {
        let view = TaskListViewController()
        let interactor = TaskListInteractor(networkService: networkService, taskStorageService: taskStorageService)
        let presenter = TaskListPresenter(router: appRouter, view: view, interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        
        return view
    }
}
