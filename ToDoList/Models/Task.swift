//
//  Task.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import Foundation

struct Task: Identifiable {
    let id: Int
    let title: String
    let isCompleted: Bool
    let date: Date
    var description: String?
}
