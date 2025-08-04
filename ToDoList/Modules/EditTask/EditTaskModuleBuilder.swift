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
    
    static func build(task: Task, dependencyContainer: AppDependencyContainer, delegate: EditTaskModuleDelegate?) -> UIViewController {
        let presenter = EditTaskPresenter(task: task, router: dependencyContainer.appRouter)
        let view = EditTaskViewController(task: task, presenter: presenter, dateFormatter: dependencyContainer.dateFormatter)
        let interactor = EditTaskInteractor(presenter: presenter, taskStorageService: dependencyContainer.taskStorageService)
        presenter.interactor = interactor
        presenter.delegate = delegate
        return view
    }
}
