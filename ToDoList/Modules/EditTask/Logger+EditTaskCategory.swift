//
//  Logger+EditTaskCategory.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 4.08.25.
//

import Foundation
import os.log

extension Logger {
    
    static let editTask = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "EditTask")
}
