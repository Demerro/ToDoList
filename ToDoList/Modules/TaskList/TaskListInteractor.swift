//
//  TaskListInteractor.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import Foundation
import os.log

protocol TaskListInteractorToPresenterProtocol: AnyObject {
    func didReceiveTasks(_ tasks: [Task])
    func didReceiveTaskEntities(_ entities: [TaskEntity])
    func didFail(with error: Error)
    func didDeleteTask(with id: Int)
    func didCompleteTask(_ task: Task)
}

final class TaskListInteractor {
    
    private static let todosURL = URL(string: "https://dummyjson.com/todos")!
    private lazy var jsonDecoder = JSONDecoder()
    
    unowned let presenter: TaskListInteractorToPresenterProtocol
    let networkService: NetworkService
    let taskStorageService: TaskStorageService
    
    init(presenter: TaskListInteractorToPresenterProtocol, networkService: NetworkService, taskStorageService: TaskStorageService) {
        self.presenter = presenter
        self.networkService = networkService
        self.taskStorageService = taskStorageService
    }
}

extension TaskListInteractor: TaskListPresenterToInteractorProtocol {
    
    func getTasks() {
        UserDefaults.standard.hasLaunchedBefore ? getTasksFromStorage() : getTasksFromNetwork()
    }
    
    func deleteTask(_ task: Task) {
        taskStorageService.delete(id: task.id) { [weak self] error in
            if let error {
                Logger.taskList.error("Failed to delete task: \(error)")
                self?.presenter.didFail(with: error)
            } else {
                Logger.taskList.info("Successfully deleted task: \(task.id)")
                self?.presenter.didDeleteTask(with: task.id)
            }
        }
    }
    
    func completeTask(_ task: consuming Task) {
        taskStorageService.update(id: task.id, isCompleted: !task.isCompleted) { [weak self] error in
            if let error {
                Logger.taskList.error("Failed to change completion for task: \(error)")
                self?.presenter.didFail(with: error)
            } else {
                Logger.taskList.info("Successfully changed completion for task: \(task.id)")
                task.isCompleted.toggle()
                self?.presenter.didCompleteTask(task)
            }
        }
    }
}

extension TaskListInteractor {
    
    private func getTasksFromNetwork() {
        networkService.data(for: URLRequest(url: Self.todosURL)) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                do {
                    Logger.taskList.info("Successfully fetched tasks from network.")
                    let taskDTOs = try jsonDecoder.decode(TaskResults.self, from: data).todos
                    saveTasksToStorage(taskDTOs: taskDTOs)
                } catch {
                    Logger.taskList.error("Failed to decode tasks: \(error)")
                    presenter.didFail(with: error)
                }
            case .failure(let error):
                Logger.taskList.error("Failed to fetch tasks from network: \(error)")
                presenter.didFail(with: error)
            }
        }
    }
    
    private func getTasksFromStorage() {
        taskStorageService.getAllTasks { [weak presenter] result in
            guard let presenter else { return }
            switch result {
            case .success(let entities):
                Logger.taskList.info("Successfully fetched tasks from storage.")
                presenter.didReceiveTaskEntities(entities)
            case .failure(let error):
                Logger.taskList.error("Failed to fetch tasks from storage: \(error)")
                presenter.didFail(with: error)
            }
        }
    }
}

extension TaskListInteractor {
    
    private func saveTasksToStorage(taskDTOs: [TaskDTO]) {
        let tasks = taskDTOs.map { Task(id: $0.id, title: $0.todo, isCompleted: $0.completed, date: Date()) }
        taskStorageService.create(tasks: tasks) { [weak presenter] error in
            if let error {
                Logger.taskList.error("Failed to create tasks in storage: \(error)")
                presenter?.didFail(with: error)
            } else {
                Logger.taskList.info("Successfully created tasks in storage.")
                presenter?.didReceiveTasks(tasks)
                UserDefaults.standard.setHasLaunchedBefore(true)
            }
        }
    }
}

extension UserDefaults {
    
    fileprivate static let hasLaunchedBefore = "hasLaunchedBefore"
    
    fileprivate var hasLaunchedBefore: Bool {
        bool(forKey: UserDefaults.hasLaunchedBefore)
    }
    
    fileprivate func setHasLaunchedBefore(_ value: Bool) {
        set(value, forKey: UserDefaults.hasLaunchedBefore)
    }
}
