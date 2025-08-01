//
//  TaskListViewController.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

protocol TaskListViewInput: AnyObject {
}

protocol TaskListViewOutput: AnyObject {
}

final class TaskListViewController: UIViewController {
    
    weak var output: TaskListViewOutput? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
    }
}

extension TaskListViewController: TaskListViewInput {
}
