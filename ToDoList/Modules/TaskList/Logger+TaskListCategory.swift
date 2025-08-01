//
//  Logger+TaskListCategory.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import Foundation
import os.log

extension Logger {
    
    static let taskList = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TaskList")
}
