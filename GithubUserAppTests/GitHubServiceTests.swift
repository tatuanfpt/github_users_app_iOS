//
//  GitHubServiceTests.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//

import XCTest
@testable import GithubUserApp

class MockAPIClient: APIClientProtocol {
    var mockResult: Result<[GitHubUser], Error>?
    var lastURL: URL?

    func request<T: Decodable>(_ url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        lastURL = url
        guard let result = mockResult else {
            XCTFail("Mock result not set")
            return
        }
        
        switch result {
        case .success(let users):
            if let typedUsers = users as? T {
                completion(.success(typedUsers))
            } else {
                XCTFail("Type mismatch in mock result")
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

class GitHubServiceTests: XCTestCase {
    var service: GitHubService!
    var mockClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        mockClient = MockAPIClient()
        service = GitHubService(client: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        service = nil
        super.tearDown()
    }

    func testFetchUsersSuccess() {
        let expectation = XCTestExpectation(description: "Fetch users")
        let mockUsers = [GitHubUser(id: 1, login: "test", avatarUrl: URL(string: "https://avatar.com")!, htmlUrl: URL(string: "https://github.com")!)]
        mockClient.mockResult = .success(mockUsers)

        service.fetchUsers(perPage: 20, since: 0) { result in
            switch result {
            case .success(let users):
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users.first?.login, "test")
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchUsersFailure() {
        let expectation = XCTestExpectation(description: "Fetch users failure")
        let mockError = NSError(domain: "", code: -1, userInfo: nil)
        mockClient.mockResult = .failure(mockError)

        service.fetchUsers(perPage: 20, since: 0) { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual((error as NSError).code, -1)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
