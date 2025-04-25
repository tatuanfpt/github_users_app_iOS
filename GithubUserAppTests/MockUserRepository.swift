import Foundation
@testable import GithubUserApp

class MockUserRepository: UserRepositoryProtocol {
    var savedUsers: [GitHubUser] = []
    var savedUserDetails: [String: GitHubUserDetail] = [:]
    var shouldFail = false
    
    func saveUsers(_ users: [GitHubUser]) {
        if shouldFail {
            return
        }
        savedUsers = users
    }
    
    func fetchUsers() -> [GitHubUser] {
        if shouldFail {
            return []
        }
        return savedUsers
    }
    
    func saveUserDetail(_ user: GitHubUserDetail) {
        if shouldFail {
            return
        }
        savedUserDetails[user.login] = user
    }
    
    func fetchUserDetail(login: String) -> GitHubUserDetail? {
        if shouldFail {
            return nil
        }
        return savedUserDetails[login]
    }
    
    func clearAllData() {
        savedUsers = []
        savedUserDetails = [:]
    }
} 