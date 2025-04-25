//
//  UserListViewModelTests.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//

import XCTest
import CoreData
@testable import GithubUserApp

// MARK: - Mock GitHub Service

class MockGitHubService: GitHubServiceProtocol {
    var users: [GitHubUser] = []
    var error: Error?
    var shouldFail: Bool = false
    
    func fetchUsers(perPage: Int, since: Int, completion: @escaping (Result<[GitHubUser], Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "Test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])))
        } else if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(users))
        }
    }
    
    func fetchUserDetail(login: String, completion: @escaping (Result<GitHubUserDetail, Error>) -> Void) {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])))
    }
}

// MARK: - Tests

class UserListViewModelTests: TestCoreDataStack {
    var viewModel: UserListViewModel!
    var mockService: MockGitHubService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockService = MockGitHubService()
        viewModel = UserListViewModel(service: mockService, coreDataStack: self)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testFetchUsers() {
    }
    
    func testSearchUsers() {
    }
    
    func testLoadMoreUsers() {
    }
    
    // MARK: - Error Handling Tests
    
    func testFetchUsersWithError() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch users with error")
        mockService.shouldFail = true
        
        viewModel.onError = { message in
            // Then
            XCTAssertFalse(message.isEmpty)
            expectation.fulfill()
        }
        
        // When
        viewModel.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCoreDataSaveError() {
    }
    
    // MARK: - Edge Cases
    
    func testEmptySearchResults() {
    }
    
    func testEmptyInitialData() {
        // Given
        let expectation = XCTestExpectation(description: "Empty initial data")
        
        viewModel.onUsersUpdated = {
            // Then
            XCTAssertTrue(self.viewModel.users.isEmpty)
            expectation.fulfill()
        }
        
        // When
        viewModel.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDuplicateUserHandling() {
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithLargeDataset() {
    }
}
