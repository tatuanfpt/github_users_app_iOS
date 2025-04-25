//
//  UserDetailViewModel.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//


import Foundation

/// ViewModel for managing user detail
class UserDetailViewModel {
    private let service: GitHubServiceProtocol
    private let repository: UserRepositoryProtocol
    private var userDetail: GitHubUserDetail?

    var onUserDetailUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(service: GitHubServiceProtocol = GitHubService(),
         repository: UserRepositoryProtocol = UserRepository(coreDataStack: CoreDataStack.shared)) {
        self.service = service
        self.repository = repository
    }

    func fetchUserDetail(login: String) {
        // First try to load from cache
        if let cachedDetail = repository.fetchUserDetail(login: login) {
            self.userDetail = cachedDetail
            self.onUserDetailUpdated?()
            return
        }

        // If not in cache, fetch from network
        service.fetchUserDetail(login: login) { [weak self] result in
            switch result {
            case .success(let detail):
                self?.userDetail = detail
                self?.repository.saveUserDetail(detail)
                self?.onUserDetailUpdated?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    var login: String {
        return userDetail?.login ?? ""
    }

    var avatarUrl: URL? {
        return userDetail?.avatarUrl
    }

    var htmlUrl: URL? {
        return userDetail?.htmlUrl
    }

    var location: String {
        return userDetail?.location ?? "N/A"
    }

    var followers: Int {
        return userDetail?.followers ?? 0
    }

    var following: Int {
        return userDetail?.following ?? 0
    }
}
