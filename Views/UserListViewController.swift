//
//  UserListViewController.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//


import UIKit

/// Displays a paginated list of GitHub users
class UserListViewController: UIViewController {
    private var viewModel: UserListViewModel!
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Initialization
    
    /// Initialize with a custom view model (for programmatic creation)
    init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Initialize from storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = UserListViewModel() // Default view model for storyboard
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchUsers()
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        title = "GitHub Users"
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.00) // Light gray background

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.reuseIdentifier) // Register new cell
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none // Remove separators
        tableView.backgroundColor = .clear // Make table view background clear
        tableView.showsVerticalScrollIndicator = false
        // Add some padding to the table view content itself if needed via contentInset or constraints
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onUsersUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfUsers
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the custom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseIdentifier, for: indexPath) as? UserTableViewCell else {
            fatalError("Unable to dequeue UserTableViewCell")
        }
        let user = viewModel.user(at: indexPath.row)
        // Configure the custom cell
        cell.configure(with: user)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Adjust height to accommodate padding and cell content
        // Cell height = Avatar height (60) + Vertical Padding inside container (implicit) + Container padding (8 * 2) + Inter-cell spacing (implicit via container padding)
        // Let's estimate around 80-90 points. Needs testing.
        return 84 // 60 (avatar) + 16 (internal padding top/bottom) + 8 (container margin top/bottom)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfUsers - 1 {
            viewModel.fetchUsers()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect immediately
        let user = viewModel.user(at: indexPath.row)
        // Initialize UserDetailViewModel with its default initializer
        let detailViewModel = UserDetailViewModel() // USE default init
        let detailVC = UserDetailViewController(login: user.login, viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
