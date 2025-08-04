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

    var interactor: EditTaskPresenterToInteractorProtocol? = nil
    
    private var task: Task
    let router: AppRouterProtocol
    
    init(task: Task, router: AppRouterProtocol) {
        self.task = task
        self.router = router
    }
}

extension EditTaskPresenter: EditTaskViewToPresenterProtocol {
    
    func textViewDidChange(text: String) {
        saveWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            task.description = text
            interactor?.saveTask(task)
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
