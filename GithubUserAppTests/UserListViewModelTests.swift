//
//  UserListViewModelTests.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//

import XCTest
import CoreData
@testable import GithubUserApp

// MARK: - Tests

class UserListViewModelTests: TestCoreDataStack {
    var viewModel: UserListViewModel!
    var mockService: MockGitHubService!
    var mockRepository: MockUserRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockService = MockGitHubService()
        mockRepository = MockUserRepository()
        viewModel = UserListViewModel(service: mockService, repository: mockRepository)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
        mockRepository = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testFetchUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch users")
        let mockUsers = [
            GitHubUser(id: 1, login: "user1", avatarUrl: URL(string: "https://avatar1.com")!, htmlUrl: URL(string: "https://github1.com")!),
            GitHubUser(id: 2, login: "user2", avatarUrl: URL(string: "https://avatar2.com")!, htmlUrl: URL(string: "https://github2.com")!)
        ]
        mockService.users = mockUsers
        
        viewModel.onUsersUpdated = {
            // Then
            XCTAssertEqual(self.viewModel.numberOfUsers, 2)
            XCTAssertEqual(self.viewModel.user(at: 0).login, "user1")
            XCTAssertEqual(self.viewModel.user(at: 1).login, "user2")
            XCTAssertEqual(self.mockRepository.savedUsers.count, 2)
            expectation.fulfill()
        }
        
        // When
        viewModel.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchUsers() {
        // Given
        let mockUsers = [
            GitHubUser(id: 1, login: "user1", avatarUrl: URL(string: "https://avatar1.com")!, htmlUrl: URL(string: "https://github1.com")!),
            GitHubUser(id: 2, login: "user2", avatarUrl: URL(string: "https://avatar2.com")!, htmlUrl: URL(string: "https://github2.com")!)
        ]
        mockService.users = mockUsers
        mockRepository.savedUsers = mockUsers
        
        // When
        viewModel.loadCachedUsers()
        viewModel.searchText = "user1"
        
        // Then
        XCTAssertEqual(viewModel.numberOfUsers, 1)
        XCTAssertEqual(viewModel.user(at: 0).login, "user1")
    }
    
    func testLoadMoreUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Load more users")
        let initialUsers = [
            GitHubUser(id: 1, login: "user1", avatarUrl: URL(string: "https://avatar1.com")!, htmlUrl: URL(string: "https://github1.com")!)
        ]
        let moreUsers = [
            GitHubUser(id: 2, login: "user2", avatarUrl: URL(string: "https://avatar2.com")!, htmlUrl: URL(string: "https://github2.com")!)
        ]
        
        mockService.users = initialUsers
        viewModel.fetchUsers()
        
        mockService.users = moreUsers
        viewModel.onUsersUpdated = {
            // Then
            XCTAssertEqual(self.viewModel.numberOfUsers, 2)
            XCTAssertEqual(self.viewModel.user(at: 1).login, "user2")
            expectation.fulfill()
        }
        
        // When
        viewModel.loadMoreUsers()
        
        wait(for: [expectation], timeout: 1.0)
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
    
    func testRepositoryError() {
        // Given
        let expectation = XCTestExpectation(description: "Repository error")
        mockRepository.shouldFail = true
        mockService.users = [] // Ensure empty response from service
        
        viewModel.onUsersUpdated = {
            // Then
            XCTAssertTrue(self.viewModel.users.isEmpty)
            expectation.fulfill()
        }
        
        // When
        viewModel.fetchUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Edge Cases
    
    func testEmptySearchResults() {
        // Given
        let mockUsers = [
            GitHubUser(id: 1, login: "user1", avatarUrl: URL(string: "https://avatar1.com")!, htmlUrl: URL(string: "https://github1.com")!)
        ]
        mockService.users = mockUsers
        mockRepository.savedUsers = mockUsers
        
        // When
        viewModel.loadCachedUsers()
        viewModel.searchText = "nonexistent"
        
        // Then
        XCTAssertEqual(viewModel.numberOfUsers, 0)
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
        // Given
        let mockUsers = [
            GitHubUser(id: 1, login: "user1", avatarUrl: URL(string: "https://avatar1.com")!, htmlUrl: URL(string: "https://github1.com")!),
            GitHubUser(id: 1, login: "user1", avatarUrl: URL(string: "https://avatar1.com")!, htmlUrl: URL(string: "https://github1.com")!)
        ]
        mockService.users = mockUsers
        
        // When
        viewModel.fetchUsers()
        
        // Then
        XCTAssertEqual(viewModel.numberOfUsers, 2)
    }
}
