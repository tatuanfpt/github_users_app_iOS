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
    
    func fetchUsers(perPage: Int, since: Int, completion: @escaping (Result<[GitHubUser], Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(users))
        }
    }
    
    func fetchUserDetail(login: String, completion: @escaping (Result<GitHubUserDetail, Error>) -> Void) {
        // Not used in these tests
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])))
    }
}

// MARK: - Tests

class UserListViewModelTests: XCTestCase {
    var sut: UserListViewModel!
    var mockService: MockGitHubService!
    var mockCoreDataStack: MockCoreDataStack!
    
    override func setUp() {
        super.setUp()
        mockService = MockGitHubService()
        mockCoreDataStack = MockCoreDataStack()
        sut = UserListViewModel(service: mockService, coreDataStack: mockCoreDataStack)
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        mockCoreDataStack = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Users Tests
    
    func testFetchUsersSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch users success")
        let mockUsers = [
            GitHubUser(id: 1, login: "user1", avatarUrl: URL(string: "https://url1.com")!, htmlUrl: URL(string: "https://html1.com")!),
            GitHubUser(id: 2, login: "user2", avatarUrl: URL(string: "https://url2.com")!, htmlUrl: URL(string: "https://html2.com")!)
        ]
        mockService.users = mockUsers
        
        sut.onUsersUpdated = {
            expectation.fulfill()
        }
        
        // When
        sut.fetchUsers()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.numberOfUsers, 2)
        XCTAssertEqual(sut.user(at: 0).login, "user1")
        XCTAssertEqual(sut.user(at: 1).login, "user2")
        
        // Verify caching
        let fetchRequest: NSFetchRequest<CachedUser> = CachedUser.fetchRequest()
        let cachedUsers = try? mockCoreDataStack.context.fetch(fetchRequest)
        XCTAssertEqual(cachedUsers?.count, 2)
        XCTAssertEqual(cachedUsers?[0].login, "user1")
        XCTAssertEqual(cachedUsers?[1].login, "user2")
    }
    
    func testFetchUsersFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch users failure")
        let expectedError = NSError(domain: "test", code: -1, userInfo: nil)
        mockService.error = expectedError
        
        sut.onError = { message in
            XCTAssertFalse(message.isEmpty)
            expectation.fulfill()
        }
        
        // When
        sut.fetchUsers()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Cache Tests
    
    func testInitialLoadWithCachedUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Load cached users")
        let context = mockCoreDataStack.context
        
        // Create cached users
        let cachedUser1 = CachedUser(context: context)
        cachedUser1.id = 1
        cachedUser1.login = "user1"
        cachedUser1.avatarUrl = "https://url1.com"
        cachedUser1.htmlUrl = "https://html1.com"
        
        let cachedUser2 = CachedUser(context: context)
        cachedUser2.id = 2
        cachedUser2.login = "user2"
        cachedUser2.avatarUrl = "https://url2.com"
        cachedUser2.htmlUrl = "https://html2.com"
        
        try? context.save()
        
        sut.onUsersUpdated = {
            expectation.fulfill()
        }
        
        // When
        sut = UserListViewModel(service: mockService, coreDataStack: mockCoreDataStack)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.numberOfUsers, 2)
        XCTAssertEqual(sut.user(at: 0).login, "user1")
        XCTAssertEqual(sut.user(at: 1).login, "user2")
    }
    
    func testCacheUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Cache users")
        let mockUsers = [
            GitHubUser(id: 1, login: "user1", avatarUrl: URL(string: "https://url1.com")!, htmlUrl: URL(string: "https://html1.com")!),
            GitHubUser(id: 2, login: "user2", avatarUrl: URL(string: "https://url2.com")!, htmlUrl: URL(string: "https://html2.com")!)
        ]
        mockService.users = mockUsers
        
        sut.onUsersUpdated = {
            expectation.fulfill()
        }
        
        // When
        sut.fetchUsers()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        let fetchRequest: NSFetchRequest<CachedUser> = CachedUser.fetchRequest()
        let cachedUsers = try? mockCoreDataStack.context.fetch(fetchRequest)
        
        XCTAssertEqual(cachedUsers?.count, 2)
        XCTAssertEqual(cachedUsers?[0].login, "user1")
        XCTAssertEqual(cachedUsers?[1].login, "user2")
    }
}
