//
//  EditTaskModuleBuilder.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 2.08.25.
//

import UIKit

struct EditTaskModuleBuilder {
    
    static func build(task: Task, taskStorageService: TaskStorageService) -> UIViewController {
        let view = EditTaskViewController(task: task)
        let interactor = EditTaskInteractor(taskStorageService: taskStorageService)
        let presenter = EditTaskPresenter(task: task, interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        
        return view
    }
}
