//
//  APIClientProtocol.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//


import Foundation

/// Protocol for network requests to enable mocking in tests
protocol APIClientProtocol {
    func request<T: Decodable>(_ url: URL, completion: @escaping (Result<T, Error>) -> Void)
}

/// Handles network requests using URLSession
class APIClient: APIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
