//
//  EditTaskPresenter.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 2.08.25.
//

import Foundation

protocol EditTaskPresenterToViewProtocol: AnyObject {
}

protocol EditTaskPresenterToInteractorProtocol: AnyObject {
    
    func saveTask(_ task: Task)
}

final class EditTaskPresenter {
    
    private var saveWorkItem: DispatchWorkItem? = nil
    
    private var task: Task
    let interactor: EditTaskPresenterToInteractorProtocol
    let router: AppRouterProtocol
    
    init(task: Task, router: AppRouterProtocol, interactor: EditTaskPresenterToInteractorProtocol) {
        self.task = task
        self.router = router
        self.interactor = interactor
    }
}

extension EditTaskPresenter: EditTaskViewToPresenterProtocol {
    
    func textViewDidChange(text: String) {
        saveWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            task.description = text
            interactor.saveTask(task)
        }
        saveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: workItem)
    }
}

extension EditTaskPresenter: EditTaskInteractorToPresenterProtocol {
    
    func didFailToUpdateTask(with error: any Error) {
        router.showErrorAlert(title: "Oops! An error occurred.", message: error.localizedDescription)
    }
}
