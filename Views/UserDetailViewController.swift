//
//  UserDetailViewController.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//


import UIKit

/// Displays detailed information about a GitHub user
class UserDetailViewController: UIViewController {
    private let viewModel: UserDetailViewModel
    private let loginLabel = UILabel()
    private let locationLabel = UILabel()
    private let followersLabel = UILabel()
    private let followingLabel = UILabel()
    private let avatarImageView = UIImageView()

    init(login: String, viewModel: UserDetailViewModel = UserDetailViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.fetchUserDetail(login: login)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "User Details"

        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)

        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        followersLabel.translatesAutoresizingMaskIntoConstraints = false
        followingLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [loginLabel, locationLabel, followersLabel, followingLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),

            stackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func bindViewModel() {
        viewModel.onUserDetailUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.loginLabel.text = "Login: \(self?.viewModel.login ?? "")"
                self?.locationLabel.text = "Location: \(self?.viewModel.location ?? "N/A")"
                self?.followersLabel.text = "Followers: \(self?.viewModel.followers)"
                self?.followingLabel.text = "Following: \(self?.viewModel.following)"

                if let url = self?.viewModel.avatarUrl {
                    self?.loadImage(from: url)
                }
            }
        }
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image
                }
            }
        }.resume()
    }
}
