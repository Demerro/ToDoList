//
//  Logger+Category.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 31.07.25.
//

import Foundation
import os.log

extension Logger {
    
    static let storage = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Storage")
}
