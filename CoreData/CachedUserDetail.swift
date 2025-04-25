//
//  CachedUserDetail.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//

import Foundation
import CoreData

@objc(CachedUserDetail)
public class CachedUserDetail: NSManagedObject {
    @NSManaged public var login: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var htmlUrl: String?
    @NSManaged public var location: String?
    @NSManaged public var followers: Int64
    @NSManaged public var following: Int64
    
    // MARK: - CoreData
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedUserDetail> {
        return NSFetchRequest<CachedUserDetail>(entityName: "CachedUserDetail")
    }
    
    // MARK: - Initialization
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // MARK: - Public Methods
    
    static func create(from user: GitHubUserDetail, in context: NSManagedObjectContext) {
        let cachedUser = CachedUserDetail(context: context)
        cachedUser.login = user.login
        cachedUser.avatarUrl = user.avatarUrl.absoluteString
        cachedUser.htmlUrl = user.htmlUrl.absoluteString
        cachedUser.location = user.location
        cachedUser.followers = Int64(user.followers)
        cachedUser.following = Int64(user.following)
    }
    
    static func fetchAll(in context: NSManagedObjectContext) -> [GitHubUserDetail] {
        let request = CachedUserDetail.fetchRequest()
        do {
            let cachedUsers = try context.fetch(request)
            return cachedUsers.compactMap { cachedUser -> GitHubUserDetail? in
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
            print("Failed to fetch cached user details: \(error)")
            return []
        }
    }
} 