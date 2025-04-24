//
//  Application.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//

import UIKit

final class Application {
    
    static let shared = Application()
    private init() {
        
    }
    
    func configureMainInterface(_ window: UIWindow = UIWindow()) {
        var expectViewController: UIViewController!
        expectViewController = UserListViewController(viewModel: UserListViewModel())
        expectViewController.title = "GithubUserApp"
        if let window = UIApplication.shared.windows.first {
            let navigationController = UINavigationController(rootViewController: expectViewController)
            window.rootViewController = navigationController
        }
        
    }
}
