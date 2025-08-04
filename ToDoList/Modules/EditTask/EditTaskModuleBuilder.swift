//
//  EditTaskModuleBuilder.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 2.08.25.
//

import UIKit

protocol EditTaskModuleDelegate: AnyObject {
    func editTaskModule(didUpdate task: Task)
}

struct EditTaskModuleBuilder {
    
    static func build(task: Task, appRouter: AppRouterProtocol, taskStorageService: TaskStorageService, delegate: EditTaskModuleDelegate?) -> UIViewController {
        let presenter = EditTaskPresenter(task: task, router: appRouter)
        let view = EditTaskViewController(task: task, presenter: presenter)
        let interactor = EditTaskInteractor(presenter: presenter, taskStorageService: taskStorageService)
        presenter.interactor = interactor
        presenter.delegate = delegate
        return view
    }
}
