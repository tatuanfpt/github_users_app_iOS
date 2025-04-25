import XCTest
@testable import GithubUserApp

class UserDetailViewModelTests: XCTestCase {
    var viewModel: UserDetailViewModel!
    var mockService: MockGitHubService!
    var mockRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockService = MockGitHubService()
        mockRepository = MockUserRepository()
        viewModel = UserDetailViewModel(service: mockService, repository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testFetchUserDetailFromNetwork() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch user detail from network")
        let mockUserDetail = GitHubUserDetail(
            login: "testuser",
            avatarUrl: URL(string: "https://avatar.com")!,
            htmlUrl: URL(string: "https://github.com")!,
            location: "Test Location",
            followers: 100,
            following: 50
        )
        mockService.userDetail = mockUserDetail
        
        viewModel.onUserDetailUpdated = {
            // Then
            XCTAssertEqual(self.viewModel.login, "testuser")
            XCTAssertEqual(self.viewModel.location, "Test Location")
            XCTAssertEqual(self.viewModel.followers, 100)
            XCTAssertEqual(self.viewModel.following, 50)
            XCTAssertEqual(self.mockRepository.savedUserDetails["testuser"]?.login, "testuser")
            expectation.fulfill()
        }
        
        // When
        viewModel.fetchUserDetail(login: "testuser")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchUserDetailFromCache() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch user detail from cache")
        let mockUserDetail = GitHubUserDetail(
            login: "testuser",
            avatarUrl: URL(string: "https://avatar.com")!,
            htmlUrl: URL(string: "https://github.com")!,
            location: "Test Location",
            followers: 100,
            following: 50
        )
        mockRepository.savedUserDetails["testuser"] = mockUserDetail
        
        viewModel.onUserDetailUpdated = {
            // Then
            XCTAssertEqual(self.viewModel.login, "testuser")
            XCTAssertEqual(self.viewModel.location, "Test Location")
            XCTAssertEqual(self.viewModel.followers, 100)
            XCTAssertEqual(self.viewModel.following, 50)
            expectation.fulfill()
        }
        
        // When
        viewModel.fetchUserDetail(login: "testuser")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testFetchUserDetailWithError() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch user detail with error")
        mockService.shouldFail = true
        
        viewModel.onError = { message in
            // Then
            XCTAssertFalse(message.isEmpty)
            expectation.fulfill()
        }
        
        // When
        viewModel.fetchUserDetail(login: "testuser")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRepositoryError() {
        // Given
        let expectation = XCTestExpectation(description: "Repository error")
        mockRepository.shouldFail = true
        mockService.userDetail = nil // Ensure network call fails
        
        viewModel.onError = { _ in
            // Then
            XCTAssertTrue(self.viewModel.login.isEmpty)
            XCTAssertEqual(self.viewModel.location, "N/A")
            expectation.fulfill()
        }
        
        // When
        viewModel.fetchUserDetail(login: "testuser")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyUserDetail() {
        // Given
        let expectation = XCTestExpectation(description: "Empty user detail")
        mockService.userDetail = nil // Ensure no mock detail is set
        
        viewModel.onError = { _ in
            // Then
            XCTAssertTrue(self.viewModel.login.isEmpty)
            XCTAssertEqual(self.viewModel.location, "N/A")
            XCTAssertEqual(self.viewModel.followers, 0)
            XCTAssertEqual(self.viewModel.following, 0)
            expectation.fulfill()
        }
        
        // When
        viewModel.fetchUserDetail(login: "nonexistent")
        
        wait(for: [expectation], timeout: 1.0)
    }
} 