//
//  NetworkServiceTests.swift
//  ToDoListTests
//
//  Created by Nikita Prokhorchuk on 5.08.25.
//

import XCTest
@testable import ToDoList

final class NetworkServiceTests: XCTestCase {
    
    var sut: NetworkService!
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        mockSession = URLSession(configuration: config)
        sut = NetworkService(session: mockSession)
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        URLProtocolStub.reset()
        super.tearDown()
    }
    
    // Helper method to create a mock session that returns nil data
    private func createMockSessionWithNilData() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocolForNilData.self]
        return URLSession(configuration: config)
    }
}

// MARK: - Success Tests
extension NetworkServiceTests {
    
    func testDataForRequest_WhenSuccessfulResponse_ReturnsData() {
        // Given
        let expectedData = """
        {
            "todos": [
                {
                    "id": 1,
                    "todo": "Do something nice for someone I care about",
                    "completed": true,
                    "userId": 26
                }
            ]
        }
        """.data(using: .utf8)!
        let request = URLRequest(url: URL(string: "https://dummyjson.com/todos")!)
        
        URLProtocolStub.stub(
            data: expectedData,
            response: HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!,
            error: nil
        )
        
        let expectation = XCTestExpectation(description: "Network request completes")
        var result: Result<Data, NetworkService.Error>?
        
        // When
        sut.data(for: request) { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success(let data):
            XCTAssertEqual(data, expectedData)
            
            // Verify JSON can be parsed
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            XCTAssertNotNil(json)
        case .failure(let error):
            XCTFail("Expected success but got error: \(error)")
        case .none:
            XCTFail("Expected result but got nil")
        }
    }
    
    func testDataForRequest_WhenCreateTodoResponse_ReturnsData() {
        // Given
        let expectedData = """
        {
            "id": 151,
            "todo": "Use DummyJSON in the project",
            "completed": false,
            "userId": 5
        }
        """.data(using: .utf8)!
        
        var request = URLRequest(url: URL(string: "https://dummyjson.com/todos/add")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLProtocolStub.stub(
            data: expectedData,
            response: HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!,
            error: nil
        )
        
        let expectation = XCTestExpectation(description: "Network request completes")
        var result: Result<Data, NetworkService.Error>?
        
        // When
        sut.data(for: request) { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success(let data):
            XCTAssertEqual(data, expectedData)
        case .failure(let error):
            XCTFail("Expected success but got error: \(error)")
        case .none:
            XCTFail("Expected result but got nil")
        }
    }
}

// MARK: - Server Error Tests
extension NetworkServiceTests {
    
    func testDataForRequest_WhenNotFound_ReturnsServerError() {
        // Given
        let request = URLRequest(url: URL(string: "https://dummyjson.com/todos/999999")!)
        let errorData = """
        {
            "message": "Todo with id '999999' not found"
        }
        """.data(using: .utf8)!
        
        URLProtocolStub.stub(
            data: errorData,
            response: HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!,
            error: nil
        )
        
        let expectation = XCTestExpectation(description: "Network request completes")
        var result: Result<Data, NetworkService.Error>?
        
        // When
        sut.data(for: request) { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            if case .server(let httpResponse) = error {
                XCTAssertEqual(httpResponse.statusCode, 404)
            } else {
                XCTFail("Expected server error but got: \(error)")
            }
        case .none:
            XCTFail("Expected result but got nil")
        }
    }
    
    func testDataForRequest_WhenBadRequest_ReturnsServerError() {
        // Given
        var request = URLRequest(url: URL(string: "https://dummyjson.com/todos/add")!)
        request.httpMethod = "POST"
        // Missing Content-Type header to simulate bad request
        
        URLProtocolStub.stub(
            data: nil,
            response: HTTPURLResponse(
                url: request.url!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil
            )!,
            error: nil
        )
        
        let expectation = XCTestExpectation(description: "Network request completes")
        var result: Result<Data, NetworkService.Error>?
        
        // When
        sut.data(for: request) { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            if case .server(let httpResponse) = error {
                XCTAssertEqual(httpResponse.statusCode, 400)
            } else {
                XCTFail("Expected server error but got: \(error)")
            }
        case .none:
            XCTFail("Expected result but got nil")
        }
    }
    
    func testDataForRequest_WhenServerError500_ReturnsServerError() {
        // Given
        let request = URLRequest(url: URL(string: "https://dummyjson.com/todos")!)
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        
        URLProtocolStub.stub(
            data: nil,
            response: response,
            error: nil
        )
        
        let expectation = XCTestExpectation(description: "Network request completes")
        var result: Result<Data, NetworkService.Error>?
        
        // When
        sut.data(for: request) { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            if case .server(let httpResponse) = error {
                XCTAssertEqual(httpResponse.statusCode, 500)
            } else {
                XCTFail("Expected server error but got: \(error)")
            }
        case .none:
            XCTFail("Expected result but got nil")
        }
    }
}

// MARK: - Client Error Tests
extension NetworkServiceTests {
    
    func testDataForRequest_WhenURLError_ReturnsClientOrTransportSpecificError() {
        // Given
        let request = URLRequest(url: URL(string: "https://api.example.com/tasks")!)
        let urlError = URLError(.notConnectedToInternet)
        
        URLProtocolStub.stub(
            data: nil,
            response: nil,
            error: urlError
        )
        
        let expectation = XCTestExpectation(description: "Network request completes")
        var result: Result<Data, NetworkService.Error>?
        
        // When
        sut.data(for: request) { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            if case .clientOrTransportSpecific(let receivedURLError) = error {
                XCTAssertEqual(receivedURLError.code, urlError.code)
            } else {
                XCTFail("Expected clientOrTransportSpecific error but got: \(error)")
            }
        case .none:
            XCTFail("Expected result but got nil")
        }
    }
    
    func testDataForRequest_WhenGenericError_ReturnsClientOrTransportError() {
        // Given
        let request = URLRequest(url: URL(string: "https://api.example.com/tasks")!)
        let genericError = NSError(domain: "TestDomain", code: 123, userInfo: nil)
        
        URLProtocolStub.stub(
            data: nil,
            response: nil,
            error: genericError
        )
        
        let expectation = XCTestExpectation(description: "Network request completes")
        var result: Result<Data, NetworkService.Error>?
        
        // When
        sut.data(for: request) { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            if case .clientOrTransport(let receivedError) = error {
                XCTAssertEqual((receivedError as NSError).code, 123)
                XCTAssertEqual((receivedError as NSError).domain, "TestDomain")
            } else {
                XCTFail("Expected clientOrTransport error but got: \(error)")
            }
        case .none:
            XCTFail("Expected result but got nil")
        }
    }
}

// MARK: - Edge Case Tests
extension NetworkServiceTests {
    
    func testDataForRequest_WhenNonHTTPResponse_ReturnsUnknownError() {
        // Given
        let request = URLRequest(url: URL(string: "https://api.example.com/tasks")!)
        let data = "Test data".data(using: .utf8)!
        
        URLProtocolStub.stub(
            data: data,
            response: URLResponse(url: request.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil),
            error: nil
        )
        
        let expectation = XCTestExpectation(description: "Network request completes")
        var result: Result<Data, NetworkService.Error>?
        
        // When
        sut.data(for: request) { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            if case .unknown = error {
                // Success - this is what we expected
            } else {
                XCTFail("Expected unknown error but got: \(error)")
            }
        case .none:
            XCTFail("Expected result but got nil")
        }
    }
}

// MARK: - Integration Tests (Real API)
extension NetworkServiceTests {
    
    func testRealAPIRequest_GetTodos_WhenNetworkAvailable() {
        // Given
        let realNetworkService = NetworkService() // Using default URLSession
        let request = URLRequest(url: URL(string: "https://dummyjson.com/todos?limit=5")!)
        
        let expectation = XCTestExpectation(description: "Real API request completes")
        var result: Result<Data, NetworkService.Error>?
        
        // When
        realNetworkService.data(for: request) { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 10.0) // Longer timeout for real network
        
        switch result {
        case .success(let data):
            // Verify we got valid JSON
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                XCTAssertNotNil(json)
                XCTAssertNotNil(json?["todos"] as? [[String: Any]])
                print("✅ Real API test passed - received \(data.count) bytes")
            } catch {
                XCTFail("Failed to parse JSON response: \(error)")
            }
        case .failure(let error):
            // For integration tests, we can accept network failures in CI/testing environments
            print("⚠️ Real API test failed (this might be expected in CI): \(error)")
        case .none:
            XCTFail("Expected result but got nil")
        }
    }
    
    func testRealAPIRequest_GetSingleTodo_WhenNetworkAvailable() {
        // Given
        let realNetworkService = NetworkService()
        let request = URLRequest(url: URL(string: "https://dummyjson.com/todos/1")!)
        
        let expectation = XCTestExpectation(description: "Real API request completes")
        var result: Result<Data, NetworkService.Error>?
        
        // When
        realNetworkService.data(for: request) { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 10.0)
        
        switch result {
        case .success(let data):
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                XCTAssertNotNil(json)
                XCTAssertNotNil(json?["id"])
                XCTAssertNotNil(json?["todo"])
                XCTAssertNotNil(json?["completed"])
                print("✅ Single todo API test passed")
            } catch {
                XCTFail("Failed to parse JSON response: \(error)")
            }
        case .failure(let error):
            print("⚠️ Real API test failed (this might be expected in CI): \(error)")
        case .none:
            XCTFail("Expected result but got nil")
        }
    }
}

// MARK: - URLProtocolStub
final class URLProtocolStub: URLProtocol {
    
    private static var stubData: Data?
    private static var stubResponse: URLResponse?
    private static var stubError: Error?
    private static var shouldProvideNoData: Bool = false
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stubData = data
        stubResponse = response
        stubError = error
        shouldProvideNoData = false
    }
    
    static func stubWithNoData(response: URLResponse) {
        stubData = nil
        stubResponse = response
        stubError = nil
        shouldProvideNoData = true
    }
    
    static func reset() {
        stubData = nil
        stubResponse = nil
        stubError = nil
        shouldProvideNoData = false
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = URLProtocolStub.stubError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        if let response = URLProtocolStub.stubResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        // If we should provide no data, don't call didLoad at all
        if !URLProtocolStub.shouldProvideNoData {
            if let dataToLoad = URLProtocolStub.stubData {
                client?.urlProtocol(self, didLoad: dataToLoad)
            }
            // If stubData is nil and we're not in no-data mode, provide empty data
            else {
                client?.urlProtocol(self, didLoad: Data())
            }
        }
        // When shouldProvideNoData is true, we don't call didLoad at all
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // Nothing to do here
    }
}

// MARK: - MockURLProtocolForNilData
class MockURLProtocolForNilData: URLProtocol {
    
    private static var stubResponse: URLResponse?
    private static var stubError: Error?
    
    static func stub(response: URLResponse?, error: Error?) {
        stubResponse = response
        stubError = error
    }
    
    static func reset() {
        stubResponse = nil
        stubError = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocolForNilData.stubError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        if let response = MockURLProtocolForNilData.stubResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        // Do not call didLoad at all to simulate nil data response
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // Nothing to do here
    }
}
