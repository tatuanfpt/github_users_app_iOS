import Foundation
@testable import GithubUserApp

class MockGitHubService: GitHubServiceProtocol {
    var users: [GitHubUser] = []
    var userDetail: GitHubUserDetail?
    var error: Error?
    var shouldFail = false
    
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
        if shouldFail {
            completion(.failure(NSError(domain: "Test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])))
        } else if let error = error {
            completion(.failure(error))
        } else if let detail = userDetail {
            completion(.success(detail))
        } else {
            completion(.failure(NSError(domain: "Test", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
        }
    }
} 