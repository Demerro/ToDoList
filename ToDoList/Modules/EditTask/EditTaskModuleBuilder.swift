//
//  EditTaskModuleBuilder.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 2.08.25.
//

import UIKit

struct EditTaskModuleBuilder {
    
    static func build(task: Task, appRouter: AppRouterProtocol, taskStorageService: TaskStorageService) -> UIViewController {
        let presenter = EditTaskPresenter(task: task, router: appRouter)
        let view = EditTaskViewController(task: task, presenter: presenter)
        let interactor = EditTaskInteractor(presenter: presenter, taskStorageService: taskStorageService)
        presenter.interactor = interactor
        return view
    }
}
