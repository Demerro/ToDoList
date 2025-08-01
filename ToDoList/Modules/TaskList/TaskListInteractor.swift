//
//  TaskListInteractor.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import Foundation
import os.log

protocol TaskListInteractorToPresenterProtocol: AnyObject {
    func didReceiveDTOs(_ taskDTOs: [TaskDTO])
    func didReceiveTaskEntities(_ entities: [TaskEntity])
    func didFailToReceiveTasks(with error: Error)
}

final class TaskListInteractor {
    
    private static let todosURL = URL(string: "https://dummyjson.com/todos")!
    private lazy var jsonDecoder = JSONDecoder()
    
    var presenter: TaskListInteractorToPresenterProtocol? = nil
    
    let networkService: NetworkService
    let taskStorageService: TaskStorageService
    
    init(networkService: NetworkService, taskStorageService: TaskStorageService) {
        self.networkService = networkService
        self.taskStorageService = taskStorageService
    }
}

extension TaskListInteractor: TaskListPresenterToInteractorProtocol {
    
    func getTasks() {
        UserDefaults.standard.hasLaunchedBefore ? getTasksFromStorage() : getTasksFromNetwork()
    }
}

extension TaskListInteractor {
    
    private func getTasksFromNetwork() {
        networkService.data(for: URLRequest(url: Self.todosURL)) { [weak self] result in
            guard let self, let presenter else { return }
            switch result {
            case .success(let data):
                do {
                    Logger.taskList.info("Successfully fetched tasks from network.")
                    presenter.didReceiveDTOs(try jsonDecoder.decode(TaskResults.self, from: data).todos)
                } catch {
                    Logger.taskList.error("Failed to decode tasks: \(error)")
                    presenter.didFailToReceiveTasks(with: error)
                }
            case .failure(let error):
                Logger.taskList.error("Failed to fetch tasks from network: \(error)")
                presenter.didFailToReceiveTasks(with: error)
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
                presenter.didFailToReceiveTasks(with: error)
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
