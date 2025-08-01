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

// MARK: - Create Tests
extension TaskStorageServiceTests {
    
    func testCreateTask() {
        // Given
        let title = "Test Task"
        let description = "Test Description"
        let date = Date()
        let isCompleted = false
        
        // When
        sut.create(title: title, taskDescription: description, date: date, isCompleted: isCompleted)
        
        // Then
        let expectation = XCTestExpectation(description: "Task created")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.sut.getAllTasks { result in
                switch result {
                case .success(let tasks):
                    XCTAssertEqual(tasks.count, 1)
                    let task = tasks.first!
                    XCTAssertEqual(task.title, title)
                    XCTAssertEqual(task.taskDescription, description)
                    XCTAssertEqual(task.isCompleted, isCompleted)
                case .failure:
                    XCTFail("Failed to fetch tasks")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateMultipleTasks() {
        // Given
        let tasksCount = 3
        
        // When
        for i in 0..<tasksCount {
            sut.create(title: "Task \(i)", taskDescription: "Description \(i)", date: Date(), isCompleted: false)
        }
        
        // Then
        let expectation = XCTestExpectation(description: "Multiple tasks created")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.sut.getAllTasks { result in
                switch result {
                case .success(let tasks):
                    XCTAssertEqual(tasks.count, tasksCount)
                case .failure:
                    XCTFail("Failed to fetch tasks")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Read Tests
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
        
        sut.create(title: "Earlier Task", taskDescription: "Description", date: earlierDate, isCompleted: false)
        sut.create(title: "Later Task", taskDescription: "Description", date: laterDate, isCompleted: false)
        
        // When & Then
        let expectation = XCTestExpectation(description: "Tasks sorted by date")
        
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
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Update Tests
extension TaskStorageServiceTests {
    
    func testUpdateTaskTitle() {
        // Given
        let originalTitle = "Original Title"
        let newTitle = "Updated Title"
        
        sut.create(title: originalTitle, taskDescription: "Description", date: Date(), isCompleted: false)
        
        let expectation = XCTestExpectation(description: "Task title updated")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // Get the created task UUID
            self.sut.getAllTasks { result in
                switch result {
                case .success(let tasks):
                    guard let task = tasks.first else {
                        XCTFail("No task found")
                        expectation.fulfill()
                        return
                    }
                    
                    // When - update the title
                    self.sut.update(uuid: task.uuid, title: newTitle) { error in
                        XCTAssertNil(error)
                        
                        // Then - verify the update
                        self.sut.getAllTasks { result in
                            switch result {
                            case .success(let updatedTasks):
                                XCTAssertEqual(updatedTasks.count, 1)
                                XCTAssertEqual(updatedTasks.first?.title, newTitle)
                                XCTAssertEqual(updatedTasks.first?.uuid, task.uuid)
                            case .failure:
                                XCTFail("Failed to fetch updated tasks")
                            }
                            expectation.fulfill()
                        }
                    }
                case .failure:
                    XCTFail("Failed to fetch tasks")
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testUpdateNonExistentTask() {
        // Given
        let nonExistentUUID = UUID()
        
        // When & Then
        let expectation = XCTestExpectation(description: "Update non-existent task")
        
        sut.update(uuid: nonExistentUUID, title: "New Title") { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Delete Tests
extension TaskStorageServiceTests {
    
    func testDeleteExistingTask() {
        // Given
        sut.create(title: "Task to Delete", taskDescription: "Description", date: Date(), isCompleted: false)
        
        let expectation = XCTestExpectation(description: "Task deleted")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // Get the created task UUID
            self.sut.getAllTasks { result in
                switch result {
                case .success(let tasks):
                    guard let task = tasks.first else {
                        XCTFail("No task found")
                        expectation.fulfill()
                        return
                    }
                    
                    // When - delete the task
                    self.sut.delete(uuid: task.uuid)
                    
                    // Then - verify deletion
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.sut.getAllTasks { result in
                            switch result {
                            case .success(let remainingTasks):
                                XCTAssertTrue(remainingTasks.isEmpty)
                            case .failure:
                                XCTFail("Failed to fetch tasks after deletion")
                            }
                            expectation.fulfill()
                        }
                    }
                case .failure:
                    XCTFail("Failed to fetch tasks")
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testDeleteNonExistentTask() {
        // Given
        let nonExistentUUID = UUID()
        
        // When
        sut.delete(uuid: nonExistentUUID)
        
        // Then - verify no crash and tasks remain empty
        let expectation = XCTestExpectation(description: "Delete non-existent task")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.sut.getAllTasks { result in
                switch result {
                case .success(let tasks):
                    XCTAssertTrue(tasks.isEmpty)
                case .failure:
                    XCTFail("Failed to fetch tasks")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
