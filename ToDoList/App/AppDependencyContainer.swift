//
//  AppDependencyContainer.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

final class AppDependencyContainer {
    
    private(set) lazy var coreDataStack = CoreDataStack()
    
    private(set) lazy var taskStorageService = TaskStorageService(coreDataStack: coreDataStack)
    
    private(set) lazy var networkService = NetworkService()
    
    private(set) lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(languageCode: .english, languageRegion: .unitedStates)
        return formatter
    }()
    
    private(set) lazy var appRouter = AppRouter(dependencyContainer: self)
}
