//
//  UserListViewModelTests.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//

import XCTest
import CoreData
@testable import GithubUserApp

// MARK: - Test CoreData Stack

class TestCoreDataStack: CoreDataStackProtocol {
    private let container: NSPersistentContainer
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    init() {
        container = NSPersistentContainer(name: "GithubUserApp")
        
        // Create in-memory store description
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load test Core Data stack: \(error)")
            }
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving test context: \(error)")
            }
        }
    }
}

// MARK: - Mock GitHub Service

class MockGitHubService: GitHubServiceProtocol {
    var mockUsers: [GitHubUser]?
    var mockError: Error?
    var fetchUsersCalled = false
    var lastPerPage: Int?
    var lastSince: Int?
    
    func fetchUsers(perPage: Int, since: Int, completion: @escaping (Result<[GitHubUser], Error>) -> Void) {
        fetchUsersCalled = true
        lastPerPage = perPage
        lastSince = since
        
        if let error = mockError {
            completion(.failure(error))
        } else if let users = mockUsers {
            completion(.success(users))
        }
    }
    
    func fetchUserDetail(login: String, completion: @escaping (Result<GitHubUserDetail, Error>) -> Void) {
        // Not used in these tests
    }
}

// MARK: - Tests

class UserListViewModelTests: XCTestCase {
    var viewModel: UserListViewModel!
    var mockGitHubService: MockGitHubService!
    var testCoreDataStack: TestCoreDataStack!
    
    override func setUp() {
        super.setUp()
        testCoreDataStack = TestCoreDataStack()
        mockGitHubService = MockGitHubService()
        viewModel = UserListViewModel(service: mockGitHubService, coreDataStack: testCoreDataStack)
    }
    
    override func tearDown() {
        viewModel = nil
        mockGitHubService = nil
        testCoreDataStack = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Users Tests
    
    func testFetchUsersSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch users success")
        let mockUser = GitHubUser(id: 1, login: "testUser", avatarUrl: URL(string: "https://test.com/avatar.jpg")!, htmlUrl: URL(string: "https://test.com/user")!)
        mockGitHubService.mockUsers = [mockUser]
        
        // When
        viewModel.onUsersUpdated = {
            // Then
            XCTAssertEqual(self.viewModel.numberOfUsers, 1)
            XCTAssertEqual(self.viewModel.user(at: 0).login, "testUser")
            XCTAssertTrue(self.mockGitHubService.fetchUsersCalled)
            XCTAssertEqual(self.mockGitHubService.lastPerPage, 20)
            expectation.fulfill()
        }
        
        viewModel.fetchUsers()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchUsersFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch users failure")
        let mockError = NSError(domain: "TestError", code: -1, userInfo: nil)
        mockGitHubService.mockError = mockError
        
        // When
        viewModel.onError = { message in
            // Then
            XCTAssertFalse(message.isEmpty)
            XCTAssertTrue(self.mockGitHubService.fetchUsersCalled)
            expectation.fulfill()
        }
        
        viewModel.fetchUsers()
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Cache Tests
    
    func testInitialLoadWithCachedUsers() {
        // Given
        let mockUser = GitHubUser(id: 1, login: "testUser", avatarUrl: URL(string: "https://test.com/avatar.jpg")!, htmlUrl: URL(string: "https://test.com/user")!)
        let cachedUser = CachedUser(context: testCoreDataStack.context)
        cachedUser.id = Int64(mockUser.id)
        cachedUser.login = mockUser.login
        cachedUser.avatarUrl = mockUser.avatarUrl.absoluteString
        cachedUser.htmlUrl = mockUser.htmlUrl.absoluteString
        try? testCoreDataStack.context.save()
        
        // When
        let expectation = XCTestExpectation(description: "Initial load with cached users")
        viewModel.onUsersUpdated = {
            // Then
            XCTAssertEqual(self.viewModel.numberOfUsers, 1)
            XCTAssertEqual(self.viewModel.user(at: 0).login, "testUser")
            expectation.fulfill()
        }
        
        // The viewModel automatically loads cached users during initialization
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCacheUsers() {
        // Given
        let mockUsers = [
            GitHubUser(id: 1, login: "testUser1", avatarUrl: URL(string: "https://test.com/avatar1.jpg")!, htmlUrl: URL(string: "https://test.com/user1")!),
            GitHubUser(id: 2, login: "testUser2", avatarUrl: URL(string: "https://test.com/avatar2.jpg")!, htmlUrl: URL(string: "https://test.com/user2")!)
        ]
        mockGitHubService.mockUsers = mockUsers
        
        // When
        let expectation = XCTestExpectation(description: "Cache users")
        viewModel.onUsersUpdated = {
            // Then
            let fetchRequest: NSFetchRequest<CachedUser> = CachedUser.fetchRequest()
            let cachedUsers = try? self.testCoreDataStack.context.fetch(fetchRequest)
            
            XCTAssertEqual(cachedUsers?.count, 2)
            XCTAssertEqual(cachedUsers?.first?.login, "testUser1")
            XCTAssertEqual(cachedUsers?.last?.login, "testUser2")
            expectation.fulfill()
        }
        
        viewModel.fetchUsers()
        wait(for: [expectation], timeout: 1.0)
    }
}
