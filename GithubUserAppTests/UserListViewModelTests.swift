//
//  UserListViewModelTests.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//

import XCTest
@testable import GithubUserApp

// MARK: - Mock CoreData Stack

class MockCoreDataStack {
    private var cachedUsers: [CachedUser] = []
    
    var context: NSManagedObjectContext {
        return MockManagedObjectContext(cachedUsers: cachedUsers)
    }
    
    func saveContext() {
        // No-op for testing
    }
    
    func addCachedUser(_ user: GitHubUser) {
        let entity = NSEntityDescription.entity(forEntityName: "CachedUser", in: context)!
        let cachedUser = CachedUser(entity: entity, insertInto: nil)
        cachedUser.id = Int64(user.id)
        cachedUser.login = user.login
        cachedUser.avatarUrl = user.avatarUrl.absoluteString
        cachedUser.htmlUrl = user.htmlUrl.absoluteString
        cachedUsers.append(cachedUser)
    }
}

class MockManagedObjectContext: NSManagedObjectContext {
    private let cachedUsers: [CachedUser]
    
    init(cachedUsers: [CachedUser]) {
        self.cachedUsers = cachedUsers
        super.init(concurrencyType: .mainQueueConcurrencyType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetch<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T] {
        return cachedUsers as! [T]
    }
    
    override func save() throws {
        // No-op for testing
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

    func fetchUserDetail(login: String, completion: @escaping (Result<GitHubUserDetail, Error>) -> Void) {}
}

// MARK: - Tests

class UserListViewModelTests: XCTestCase {
    var viewModel: UserListViewModel!
    var mockService: MockGitHubService!
    var mockCoreDataStack: MockCoreDataStack!

    override func setUp() {
        super.setUp()
        mockService = MockGitHubService()
        mockCoreDataStack = MockCoreDataStack()
        viewModel = UserListViewModel(service: mockService, coreDataStack: mockCoreDataStack)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockCoreDataStack = nil
        super.tearDown()
    }

    func testFetchUsersSuccess() {
        let expectation = XCTestExpectation(description: "Fetch users")
        let mockUsers = [GitHubUser(id: 1, login: "test", avatarUrl: URL(string: "https://avatar.com")!, htmlUrl: URL(string: "https://github.com")!)]
        mockService.mockUsers = mockUsers

        viewModel.onUsersUpdated = {
            XCTAssertEqual(self.viewModel.numberOfUsers, 1)
            XCTAssertEqual(self.viewModel.user(at: 0).login, "test")
            XCTAssertTrue(self.mockService.fetchUsersCalled)
            XCTAssertEqual(self.mockService.lastPerPage, 20)
            expectation.fulfill()
        }

        viewModel.fetchUsers()
        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchUsersFailure() {
        let expectation = XCTestExpectation(description: "Fetch users failure")
        let mockError = NSError(domain: "", code: -1, userInfo: nil)
        mockService.mockError = mockError

        viewModel.onError = { message in
            XCTAssertFalse(message.isEmpty)
            XCTAssertTrue(self.mockService.fetchUsersCalled)
            expectation.fulfill()
        }

        viewModel.fetchUsers()
        wait(for: [expectation], timeout: 1.0)
    }
}
