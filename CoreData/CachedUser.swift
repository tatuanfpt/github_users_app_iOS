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
    @NSManaged public var login: String
    @NSManaged public var avatarUrl: String
    @NSManaged public var htmlUrl: String
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedUser> {
        return NSFetchRequest<CachedUser>(entityName: "CachedUser")
    }
    
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
            return cachedUsers.map { GitHubUser(id: Int($0.id), 
                                              login: $0.login ?? "",
                                              avatarUrl: URL(string: $0.avatarUrl ?? "")!,
                                              htmlUrl: URL(string: $0.htmlUrl ?? "")!) }
        } catch {
            print("Failed to fetch cached users: \(error)")
            return []
        }
    }
}


