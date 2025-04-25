//
//  UserListViewModel.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//


import Foundation

/// ViewModel for managing the user list
class UserListViewModel {
    private let service: GitHubServiceProtocol
    private let repository: UserRepositoryProtocol
    private(set) var users: [GitHubUser] = []
    private var isFetching = false
    private var lastId: Int = 0
    private let perPage = 20
    
    // Search functionality
    private(set) var filteredUsers: [GitHubUser] = []
    var searchText: String = "" {
        didSet {
            filterUsers()
        }
    }

    var onUsersUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(service: GitHubServiceProtocol = GitHubService(),
         repository: UserRepositoryProtocol = UserRepository(coreDataStack: CoreDataStack.shared)) {
        self.service = service
        self.repository = repository
        loadCachedUsers()
    }

    var numberOfUsers: Int {
        return searchText.isEmpty ? users.count : filteredUsers.count
    }

    func user(at index: Int) -> GitHubUser {
        return searchText.isEmpty ? users[index] : filteredUsers[index]
    }

    func fetchUsers() {
        guard !isFetching else { return }
        isFetching = true

        service.fetchUsers(perPage: perPage, since: lastId) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false

            switch result {
            case .success(let newUsers):
                self.users.append(contentsOf: newUsers)
                self.lastId = newUsers.last?.id ?? self.lastId
                self.repository.saveUsers(newUsers)
                self.filterUsers()
                self.onUsersUpdated?()
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
    
    func loadMoreUsers() {
        fetchUsers()
    }
    
    private func filterUsers() {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { $0.login.lowercased().contains(searchText.lowercased()) }
        }
        onUsersUpdated?()
    }

    func loadCachedUsers() {
        users = repository.fetchUsers()
        if !users.isEmpty {
            lastId = users.last?.id ?? 0
            filterUsers()
        }
        onUsersUpdated?()
    }
}
