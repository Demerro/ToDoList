//
//  TaskListModuleBuilder.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

struct TaskListModuleBuilder {
    
    static func build(networkService: NetworkService, taskStorageService: TaskStorageService) -> UIViewController {
        let view = TaskListViewController()
        let interactor = TaskListInteractor(networkService: networkService, taskStorageService: taskStorageService)
        let presenter = TaskListPresenter(view: view, interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        
        return view
    }
}
