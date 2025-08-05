//
//  TaskStorageServiceTests.swift
//  ToDoListTests
//
//  Created by Nikita Prokhorchuk on 31.07.25.
//

import XCTest
@testable import ToDoList

final class TaskStorageServiceTests: XCTestCase {
    
    var sut: TaskStorageService!
    
    override func setUp() {
        sut = TaskStorageService(coreDataStack: CoreDataStack(storeType: .inMemory))
    }
    
    override func tearDown() {
        sut = nil
    }
}

// MARK: - Create Operation Tests
extension TaskStorageServiceTests {
    
    func testCreateSingleTask() {
        // Given
        let task = Task(
            id: UUID(),
            title: "Test Task",
            isCompleted: false,
            date: Date(),
            description: "Test Description"
        )
        
        // When
        let createExpectation = XCTestExpectation(description: "Task created")
        sut.create(task: task) { error in
            XCTAssertNil(error)
            createExpectation.fulfill()
        }
        
        // Then
        let fetchExpectation = XCTestExpectation(description: "Task fetched")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.sut.getAllTasks { result in
                switch result {
                case .success(let tasks):
                    XCTAssertEqual(tasks.count, 1)
                    let taskEntity = tasks.first!
                    XCTAssertEqual(taskEntity.id, task.id)
                    XCTAssertEqual(taskEntity.title, task.title)
                    XCTAssertEqual(taskEntity.taskDescription, task.description)
                    XCTAssertEqual(taskEntity.isCompleted, task.isCompleted)
                case .failure:
                    XCTFail("Failed to fetch tasks")
                }
                fetchExpectation.fulfill()
            }
        }
        
        wait(for: [createExpectation, fetchExpectation], timeout: 1.0)
    }
    
    func testCreateMultipleTasks() {
        // Given
        let tasksCount = 3
        let createExpectations = (0..<tasksCount).map { _ in XCTestExpectation(description: "Task created") }
        
        // When
        for i in 0..<tasksCount {
            let task = Task(
                id: UUID(),
                title: "Task \(i)",
                isCompleted: false,
                date: Date(),
                description: "Description \(i)"
            )
            sut.create(task: task) { error in
                XCTAssertNil(error)
                createExpectations[i].fulfill()
            }
        }
        
        // Then
        let fetchExpectation = XCTestExpectation(description: "Multiple tasks fetched")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.sut.getAllTasks { result in
                switch result {
                case .success(let tasks):
                    XCTAssertEqual(tasks.count, tasksCount)
                case .failure:
                    XCTFail("Failed to fetch tasks")
                }
                fetchExpectation.fulfill()
            }
        }
        
        wait(for: createExpectations + [fetchExpectation], timeout: 1.0)
    }
}

// MARK: - Batch Create Operation Tests
extension TaskStorageServiceTests {
    
    func testCreateTasksArray() {
        // Given
        let tasks = [
            Task(
                id: UUID(),
                title: "Task 1",
                isCompleted: false,
                date: Date(),
                description: "Description 1"
            ),
            Task(
                id: UUID(),
                title: "Task 2",
                isCompleted: true,
                date: Date().addingTimeInterval(-3600),
                description: "Description 2"
            ),
            Task(
                id: UUID(),
                title: "Task 3",
                isCompleted: false,
                date: Date().addingTimeInterval(3600),
                description: "Description 3"
            )
        ]
        
        // When
        let createExpectation = XCTestExpectation(description: "Tasks array created")
        sut.create(tasks: tasks) { error in
            XCTAssertNil(error)
            createExpectation.fulfill()
        }
        
        // Then
        let fetchExpectation = XCTestExpectation(description: "Tasks array fetched")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.sut.getAllTasks { result in
                switch result {
                case .success(let fetchedTasks):
                    XCTAssertEqual(fetchedTasks.count, tasks.count)
                    
                    // Verify each task was created correctly
                    for task in tasks {
                        let matchingTask = fetchedTasks.first { $0.id == task.id }
                        XCTAssertNotNil(matchingTask, "Task with id \(task.id) should exist")
                        if let matchingTask = matchingTask {
                            XCTAssertEqual(matchingTask.title, task.title)
                            XCTAssertEqual(matchingTask.taskDescription, task.description)
                            XCTAssertEqual(matchingTask.isCompleted, task.isCompleted)
                        }
                    }
                case .failure:
                    XCTFail("Failed to fetch tasks")
                }
                fetchExpectation.fulfill()
            }
        }
        
        wait(for: [createExpectation, fetchExpectation], timeout: 1.0)
    }
    
    func testCreateEmptyTasksArray() {
        // Given
        let emptyTasks: [Task] = []
        
        // When
        let createExpectation = XCTestExpectation(description: "Empty tasks array created")
        sut.create(tasks: emptyTasks) { error in
            XCTAssertNil(error)
            createExpectation.fulfill()
        }
        
        // Then
        let fetchExpectation = XCTestExpectation(description: "Tasks fetched after empty array creation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.sut.getAllTasks { result in
                switch result {
                case .success(let tasks):
                    XCTAssertTrue(tasks.isEmpty)
                case .failure:
                    XCTFail("Failed to fetch tasks")
                }
                fetchExpectation.fulfill()
            }
        }
        
        wait(for: [createExpectation, fetchExpectation], timeout: 1.0)
    }
}

// MARK: - Read Operation Tests
extension TaskStorageServiceTests {
    
    func testGetAllTasksEmpty() {
        // Given - no tasks created
        
        // When & Then
        let expectation = XCTestExpectation(description: "Empty tasks list")
        
        sut.getAllTasks { result in
            switch result {
            case .success(let tasks):
                XCTAssertTrue(tasks.isEmpty)
            case .failure:
                XCTFail("Failed to fetch tasks")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetAllTasksSortedByDate() {
        // Given
        let earlierDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let laterDate = Date()
        
        let earlierTask = Task(
            id: UUID(),
            title: "Earlier Task",
            isCompleted: false,
            date: earlierDate,
            description: "Description"
        )
        
        let laterTask = Task(
            id: UUID(),
            title: "Later Task",
            isCompleted: false,
            date: laterDate,
            description: "Description"
        )
        
        let createExpectations = [
            XCTestExpectation(description: "Earlier task created"),
            XCTestExpectation(description: "Later task created")
        ]
        
        sut.create(task: earlierTask) { error in
            XCTAssertNil(error)
            createExpectations[0].fulfill()
        }
        
        sut.create(task: laterTask) { error in
            XCTAssertNil(error)
            createExpectations[1].fulfill()
        }
        
        // When & Then
        let fetchExpectation = XCTestExpectation(description: "Tasks sorted by date")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.sut.getAllTasks { result in
                switch result {
                case .success(let tasks):
                    XCTAssertEqual(tasks.count, 2)
                    // Tasks should be sorted by date descending (newer first)
                    XCTAssertEqual(tasks[0].title, "Later Task")
                    XCTAssertEqual(tasks[1].title, "Earlier Task")
                case .failure:
                    XCTFail("Failed to fetch tasks")
                }
                fetchExpectation.fulfill()
            }
        }
        
        wait(for: createExpectations + [fetchExpectation], timeout: 1.0)
    }
}

// MARK: - Update Operation Tests
extension TaskStorageServiceTests {
    
    func testUpdateTaskTitle() {
        // Given
        let originalTitle = "Original Title"
        let newTitle = "Updated Title"
        let taskId = UUID()
        
        let task = Task(
            id: taskId,
            title: originalTitle,
            isCompleted: false,
            date: Date(),
            description: "Description"
        )
        
        let createExpectation = XCTestExpectation(description: "Task created")
        sut.create(task: task) { error in
            XCTAssertNil(error)
            createExpectation.fulfill()
        }
        
        let updateExpectation = XCTestExpectation(description: "Task title updated")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // When - update the title
            self.sut.update(id: taskId, title: newTitle) { error in
                XCTAssertNil(error)
                
                // Then - verify the update
                self.sut.getAllTasks { result in
                    switch result {
                    case .success(let updatedTasks):
                        XCTAssertEqual(updatedTasks.count, 1)
                        XCTAssertEqual(updatedTasks.first?.title, newTitle)
                        XCTAssertEqual(updatedTasks.first?.id, taskId)
                    case .failure:
                        XCTFail("Failed to fetch updated tasks")
                    }
                    updateExpectation.fulfill()
                }
            }
        }
        
        wait(for: [createExpectation, updateExpectation], timeout: 2.0)
    }
    
    func testUpdateTaskDescription() {
        // Given
        let taskId = UUID()
        let newDescription = "Updated Description"
        
        let task = Task(
            id: taskId,
            title: "Title",
            isCompleted: false,
            date: Date(),
            description: "Original Description"
        )
        
        let createExpectation = XCTestExpectation(description: "Task created")
        sut.create(task: task) { error in
            XCTAssertNil(error)
            createExpectation.fulfill()
        }
        
        let updateExpectation = XCTestExpectation(description: "Task description updated")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // When
            self.sut.update(id: taskId, taskDescription: newDescription) { error in
                XCTAssertNil(error)
                
                // Then
                self.sut.getAllTasks { result in
                    switch result {
                    case .success(let tasks):
                        XCTAssertEqual(tasks.first?.taskDescription, newDescription)
                    case .failure:
                        XCTFail("Failed to fetch updated tasks")
                    }
                    updateExpectation.fulfill()
                }
            }
        }
        
        wait(for: [createExpectation, updateExpectation], timeout: 2.0)
    }
    
    func testUpdateTaskCompletion() {
        // Given
        let taskId = UUID()
        
        let task = Task(
            id: taskId,
            title: "Title",
            isCompleted: false,
            date: Date(),
            description: "Description"
        )
        
        let createExpectation = XCTestExpectation(description: "Task created")
        sut.create(task: task) { error in
            XCTAssertNil(error)
            createExpectation.fulfill()
        }
        
        let updateExpectation = XCTestExpectation(description: "Task completion updated")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // When
            self.sut.update(id: taskId, isCompleted: true) { error in
                XCTAssertNil(error)
                
                // Then
                self.sut.getAllTasks { result in
                    switch result {
                    case .success(let tasks):
                        XCTAssertEqual(tasks.first?.isCompleted, true)
                    case .failure:
                        XCTFail("Failed to fetch updated tasks")
                    }
                    updateExpectation.fulfill()
                }
            }
        }
        
        wait(for: [createExpectation, updateExpectation], timeout: 2.0)
    }
    
    func testUpdateNonExistentTask() {
        // Given
        let nonExistentId = UUID()
        
        // When & Then
        let expectation = XCTestExpectation(description: "Update non-existent task")
        
        sut.update(id: nonExistentId, title: "New Title") { error in
            XCTAssertNotNil(error)
            if let error = error, case let TaskStorageService.Error.taskNotFound(id) = error {
                XCTAssertEqual(id, nonExistentId)
            } else {
                XCTFail("Expected taskNotFound error")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Delete Operation Tests
extension TaskStorageServiceTests {
    
    func testDeleteExistingTask() {
        // Given
        let taskId = UUID()
        let task = Task(
            id: taskId,
            title: "Task to Delete",
            isCompleted: false,
            date: Date(),
            description: "Description"
        )
        
        let createExpectation = XCTestExpectation(description: "Task created")
        sut.create(task: task) { error in
            XCTAssertNil(error)
            createExpectation.fulfill()
        }
        
        let deleteExpectation = XCTestExpectation(description: "Task deleted")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // When - delete the task
            self.sut.delete(id: taskId) { error in
                XCTAssertNil(error)
                
                // Then - verify deletion
                self.sut.getAllTasks { result in
                    switch result {
                    case .success(let remainingTasks):
                        XCTAssertTrue(remainingTasks.isEmpty)
                    case .failure:
                        XCTFail("Failed to fetch tasks after deletion")
                    }
                    deleteExpectation.fulfill()
                }
            }
        }
        
        wait(for: [createExpectation, deleteExpectation], timeout: 2.0)
    }
    
    func testDeleteNonExistentTask() {
        // Given
        let nonExistentId = UUID()
        
        // When & Then
        let expectation = XCTestExpectation(description: "Delete non-existent task")
        
        sut.delete(id: nonExistentId) { error in
            XCTAssertNotNil(error)
            if let error = error, case let TaskStorageService.Error.taskNotFound(id) = error {
                XCTAssertEqual(id, nonExistentId)
            } else {
                XCTFail("Expected taskNotFound error")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
