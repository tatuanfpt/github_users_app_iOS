//
//  GitHubUser.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//


import Foundation

/// Represents a GitHub user fetched from the API
struct GitHubUser: Codable, Identifiable {
    let id: Int
    let login: String
    let avatarUrl: URL
    let htmlUrl: URL

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
    }
}

/// Represents detailed GitHub user information
struct GitHubUserDetail: Codable {
    let login: String
    let avatarUrl: URL
    let htmlUrl: URL
    let location: String?
    let followers: Int
    let following: Int

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case location
        case followers
        case following
    }
}
