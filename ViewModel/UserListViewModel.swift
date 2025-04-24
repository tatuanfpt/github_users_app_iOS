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
    private let coreDataStack: CoreDataStack
    private var users: [GitHubUser] = []
    private var isFetching = false
    private var lastId: Int = 0
    private let perPage = 20

    var onUsersUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(service: GitHubServiceProtocol = GitHubService(), coreDataStack: CoreDataStack = .shared) {
        self.service = service
        self.coreDataStack = coreDataStack
        loadCachedUsers()
    }

    var numberOfUsers: Int {
        return users.count
    }

    func user(at index: Int) -> GitHubUser {
        return users[index]
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
                self.onUsersUpdated?()
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }

    private func loadCachedUsers() {
        do {
            users = CachedUser.fetchAll(in: coreDataStack.context)
            if !users.isEmpty {
                lastId = users.last?.id ?? 0
                onUsersUpdated?()
            }
        } catch {
            print("Failed to load cached users: \(error)")
            onError?("Failed to load cached users")
        }
        fetchUsers() // Fetch fresh data in background
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
