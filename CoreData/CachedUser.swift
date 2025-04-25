//
//  CachedUser.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//

import Foundation
import CoreData

@objc(CachedUser)
public class CachedUser: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var login: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var htmlUrl: String?
    
    // MARK: - CoreData
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedUser> {
        return NSFetchRequest<CachedUser>(entityName: "CachedUser")
    }
    
    // MARK: - Initialization
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // MARK: - Public Methods
    
    static func create(from user: GitHubUser, in context: NSManagedObjectContext) {
        let cachedUser = CachedUser(context: context)
        cachedUser.id = Int64(user.id)
        cachedUser.login = user.login
        cachedUser.avatarUrl = user.avatarUrl.absoluteString
        cachedUser.htmlUrl = user.htmlUrl.absoluteString
    }
    
    static func fetchAll(in context: NSManagedObjectContext) -> [GitHubUser] {
        let request = CachedUser.fetchRequest()
        do {
            let cachedUsers = try context.fetch(request)
            return cachedUsers.compactMap { cachedUser -> GitHubUser? in
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
        } catch {
            print("Failed to fetch cached users: \(error)")
            return []
        }
    }
}


