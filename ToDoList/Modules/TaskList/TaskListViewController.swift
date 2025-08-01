//
//  TaskListViewController.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

protocol TaskListViewToPresenterProtocol: AnyObject {
    func getTasks()
}

final class TaskListViewController: UIViewController {
    
    weak var presenter: TaskListViewToPresenterProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
        presenter?.getTasks()
    }
}

extension TaskListViewController: TaskListPresenterToViewProtocol {
    
    func displayTasks(_ tasks: [Task]) {
        print(tasks)
    }
}
