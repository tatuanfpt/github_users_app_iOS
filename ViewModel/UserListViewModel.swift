//
//  UserListViewModel.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//


import Foundation
import CoreData

/// ViewModel for managing the user list
class UserListViewModel {
    private let service: GitHubServiceProtocol
    private let coreDataStack: CoreDataStackProtocol
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

    init(service: GitHubServiceProtocol = GitHubService(), coreDataStack: CoreDataStackProtocol = CoreDataStack.shared) {
        self.service = service
        self.coreDataStack = coreDataStack
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
                self.cacheUsers(newUsers)
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

    private func loadCachedUsers() {
        let fetchRequest: NSFetchRequest<CachedUser> = CachedUser.fetchRequest()
        do {
            let cachedUsers = try coreDataStack.context.fetch(fetchRequest)
            users = cachedUsers.compactMap { cachedUser -> GitHubUser? in
                guard let login = cachedUser.login,
                      let avatarUrlString = cachedUser.avatarUrl,
                      let htmlUrlString = cachedUser.htmlUrl,
                      let avatarUrl = URL(string: avatarUrlString),
                      let htmlUrl = URL(string: htmlUrlString) else {
                    return nil
                }
                return GitHubUser(id: Int(cachedUser.id),
                                login: login,
                                avatarUrl: avatarUrl,
                                htmlUrl: htmlUrl)
            }
            if !users.isEmpty {
                lastId = users.last?.id ?? 0
                filterUsers()
            }
            onUsersUpdated?()
        } catch {
            print("Failed to load cached users: \(error)")
            onError?("Failed to load cached users")
        }
    }

    private func cacheUsers(_ users: [GitHubUser]) {
        let context = coreDataStack.context
        do {
            users.forEach { CachedUser.create(from: $0, in: context) }
            try context.save()
        } catch {
            print("Failed to cache users: \(error)")
            onError?("Failed to save users to cache")
        }
    }
}
