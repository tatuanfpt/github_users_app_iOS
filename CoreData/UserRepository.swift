import Foundation
import CoreData

protocol UserRepositoryProtocol {
    func saveUsers(_ users: [GitHubUser])
    func fetchUsers() -> [GitHubUser]
    func saveUserDetail(_ user: GitHubUserDetail)
    func fetchUserDetail(login: String) -> GitHubUserDetail?
    func clearAllData()
}

class UserRepository: UserRepositoryProtocol {
    private let coreDataStack: CoreDataStackProtocol
    
    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }
    
    func saveUsers(_ users: [GitHubUser]) {
        let context = coreDataStack.context
        users.forEach { user in
            CachedUser.create(from: user, in: context)
        }
        coreDataStack.saveContext()
    }
    
    func fetchUsers() -> [GitHubUser] {
        return CachedUser.fetchAll(in: coreDataStack.context)
    }
    
    func saveUserDetail(_ user: GitHubUserDetail) {
        let context = coreDataStack.context
        CachedUserDetail.create(from: user, in: context)
        coreDataStack.saveContext()
    }
    
    func fetchUserDetail(login: String) -> GitHubUserDetail? {
        let request = CachedUserDetail.fetchRequest()
        request.predicate = NSPredicate(format: "login == %@", login)
        
        do {
            let results = try coreDataStack.context.fetch(request)
            return results.first.flatMap { cachedUser -> GitHubUserDetail? in
                guard let login = cachedUser.login,
                      let avatarUrlString = cachedUser.avatarUrl,
                      let htmlUrlString = cachedUser.htmlUrl,
                      let avatarUrl = URL(string: avatarUrlString),
                      let htmlUrl = URL(string: htmlUrlString) else {
                    return nil
                }
                return GitHubUserDetail(login: login,
                                      avatarUrl: avatarUrl,
                                      htmlUrl: htmlUrl,
                                      location: cachedUser.location,
                                      followers: Int(cachedUser.followers),
                                      following: Int(cachedUser.following))
            }
        } catch {
            print("Failed to fetch user detail: \(error)")
            return nil
        }
    }
    
    func clearAllData() {
        let context = coreDataStack.context
        
        // Delete all CachedUser entities
        let userRequest = CachedUser.fetchRequest()
        if let users = try? context.fetch(userRequest) {
            users.forEach { context.delete($0) }
        }
        
        // Delete all CachedUserDetail entities
        let detailRequest = CachedUserDetail.fetchRequest()
        if let details = try? context.fetch(detailRequest) {
            details.forEach { context.delete($0) }
        }
        
        coreDataStack.saveContext()
    }
} 