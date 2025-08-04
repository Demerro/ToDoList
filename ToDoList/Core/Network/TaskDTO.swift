//
//  TaskDTO.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import Foundation

struct TaskResults: Decodable {
    let todos: [TaskDTO]
    let total: Int
    let skip: Int
    let limit: Int
}

struct TaskDTO: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
