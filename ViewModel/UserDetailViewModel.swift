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
    private var userDetail: GitHubUserDetail?

    var onUserDetailUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(service: GitHubServiceProtocol = GitHubService()) {
        self.service = service
    }

    func fetchUserDetail(login: String) {
        service.fetchUserDetail(login: login) { [weak self] result in
            switch result {
            case .success(let detail):
                self?.userDetail = detail
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
