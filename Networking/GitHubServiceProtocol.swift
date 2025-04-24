//
//  GitHubServiceProtocol.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//


import Foundation

/// Protocol for GitHub API interactions
protocol GitHubServiceProtocol {
    func fetchUsers(perPage: Int, since: Int, completion: @escaping (Result<[GitHubUser], Error>) -> Void)
    func fetchUserDetail(login: String, completion: @escaping (Result<GitHubUserDetail, Error>) -> Void)
}

/// Service for GitHub API calls
class GitHubService: GitHubServiceProtocol {
    private let client: APIClientProtocol
    private let baseURL = "https://api.github.com"

    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }

    func fetchUsers(perPage: Int, since: Int, completion: @escaping (Result<[GitHubUser], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users?per_page=\(perPage)&since=\(since)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        client.request(url, completion: completion)
    }

    func fetchUserDetail(login: String, completion: @escaping (Result<GitHubUserDetail, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(login)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        client.request(url, completion: completion)
    }
}
