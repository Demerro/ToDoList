//
//  EditTaskModuleBuilder.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 2.08.25.
//

import UIKit

struct EditTaskModuleBuilder {
    
    static func build(task: Task, appRouter: AppRouterProtocol, taskStorageService: TaskStorageService) -> UIViewController {
        let view = EditTaskViewController(task: task)
        let interactor = EditTaskInteractor(taskStorageService: taskStorageService)
        let presenter = EditTaskPresenter(task: task, router: appRouter, interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        
        return view
    }
}
