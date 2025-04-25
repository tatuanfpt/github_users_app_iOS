//
//  UserDetailViewController.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//


import UIKit
// import Kingfisher // Removed Kingfisher import

/// Displays detailed information about a GitHub user
class UserDetailViewController: UIViewController {
    private let viewModel: UserDetailViewModel

    // --- UI Elements --- 
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Top Card Elements
    private let topCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.applyShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40 // Half of width/height
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }() 

    private let locationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // Follower/Following Card Elements
    private let followCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.applyShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let followersStackView = UIStackView.createIconLabelStack(iconName: "person.2.fill", labelText: "Followers")
    private let followingStackView = UIStackView.createIconLabelStack(iconName: "person.badge.plus.fill", labelText: "Following") // Example icon, adjust as needed

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // --- Initialization ---
    init(login: String, viewModel: UserDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        // Fetch details immediately
        viewModel.fetchUserDetail(login: login)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // --- Lifecycle ---
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        activityIndicator.startAnimating() // Start loading indicator
    }

    // --- UI Setup ---
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.00) // Match list background
        title = "User Details"

        // ScrollView Setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Activity Indicator Setup
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true

        // --- Top Card Setup ---
        contentView.addSubview(topCardView)
        topCardView.addSubview(avatarImageView)

        let locationIcon = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        locationIcon.tintColor = .secondaryLabel
        locationIcon.setContentHuggingPriority(.required, for: .horizontal)

        locationStackView.addArrangedSubview(locationIcon)
        locationStackView.addArrangedSubview(locationLabel)

        let topTextStack = UIStackView(arrangedSubviews: [nameLabel, locationStackView])
        topTextStack.axis = .vertical
        topTextStack.spacing = 6
        topTextStack.alignment = .leading
        topTextStack.translatesAutoresizingMaskIntoConstraints = false
        topCardView.addSubview(topTextStack)

        // --- Follow Card Setup ---
        contentView.addSubview(followCardView)
        let followMainStack = UIStackView(arrangedSubviews: [followersStackView, followingStackView])
        followMainStack.axis = .horizontal
        followMainStack.distribution = .fillEqually
        followMainStack.alignment = .center
        followMainStack.spacing = 16
        followMainStack.translatesAutoresizingMaskIntoConstraints = false
        followCardView.addSubview(followMainStack)

        // --- Layout Constraints ---
        let padding: CGFloat = 16
        NSLayoutConstraint.activate([
            // ScrollView Constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // ContentView Constraints (pinned to ScrollView edges and width matching ScrollView's frame layout guide)
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // Activity Indicator Constraints
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Top Card Constraints
            topCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            topCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            topCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            avatarImageView.topAnchor.constraint(equalTo: topCardView.topAnchor, constant: padding),
            avatarImageView.leadingAnchor.constraint(equalTo: topCardView.leadingAnchor, constant: padding),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),
            avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: topCardView.bottomAnchor, constant: -padding),

            topTextStack.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: padding),
            topTextStack.trailingAnchor.constraint(equalTo: topCardView.trailingAnchor, constant: -padding),
            topTextStack.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            topTextStack.topAnchor.constraint(greaterThanOrEqualTo: topCardView.topAnchor, constant: padding), // Ensure text doesn't overlap top if tall
            topTextStack.bottomAnchor.constraint(lessThanOrEqualTo: topCardView.bottomAnchor, constant: -padding), // Ensure text doesn't overlap bottom

            // Follow Card Constraints
            followCardView.topAnchor.constraint(equalTo: topCardView.bottomAnchor, constant: padding),
            followCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            followCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            followCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),

            followMainStack.topAnchor.constraint(equalTo: followCardView.topAnchor, constant: padding),
            followMainStack.bottomAnchor.constraint(equalTo: followCardView.bottomAnchor, constant: -padding),
            followMainStack.leadingAnchor.constraint(equalTo: followCardView.leadingAnchor, constant: padding),
            followMainStack.trailingAnchor.constraint(equalTo: followCardView.trailingAnchor, constant: -padding),
        ])
    }

    // --- ViewModel Binding ---
    private func bindViewModel() {
        viewModel.onUserDetailUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
                self?.activityIndicator.stopAnimating()
            }
        }
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                // Maybe hide content views on error? Or show an error view.
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    // --- UI Update ---
    private func updateUI() {
        nameLabel.text = viewModel.login
        locationLabel.text = viewModel.location
        locationStackView.isHidden = viewModel.location == "N/A"

        (followersStackView.arrangedSubviews.last as? UILabel)?.text = "\(viewModel.followers)\nFollowers"
        (followingStackView.arrangedSubviews.last as? UILabel)?.text = "\(viewModel.following)\nFollowing"

        // Set placeholder and load image
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .gray
        if let urlString = viewModel.avatarUrl?.absoluteString {
            loadImage(from: urlString) { [weak self] image in
                DispatchQueue.main.async {
                    if let loadedImage = image {
                        self?.avatarImageView.image = loadedImage
                        self?.avatarImageView.tintColor = nil
                    } else {
                         // Keep placeholder if loading failed
                        self?.avatarImageView.image = UIImage(systemName: "person.circle.fill")
                        self?.avatarImageView.tintColor = .gray
                    }
                }
            }
        }
        
        topCardView.isHidden = false
        followCardView.isHidden = false
    }
    
    // --- Image Loading Helper ---
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                #if DEBUG
                print("Error loading image from \(urlString): \(error.localizedDescription)")
                #endif
                completion(nil)
                return
            }
            if let data = data {
                completion(UIImage(data: data))
            } else {
                completion(nil)
            }
        }.resume()
    }
}

// MARK: - Helpers / Extensions

private extension UIView {
    func applyShadow(color: UIColor = .black, opacity: Float = 0.1, offset: CGSize = CGSize(width: 0, height: 4), radius: CGFloat = 6) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}

private extension UIStackView {
    static func createIconLabelStack(iconName: String, labelText: String) -> UIStackView {
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .secondaryLabel // Or customize color
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0 // Allow multiple lines for count and title
        label.text = labelText // Set initial text, will be updated
        label.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [iconImageView, label])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Set explicit size constraints for the icon
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30)
        ])

        return stackView
    }
}

// NOTE: The UIImageView extension is likely already defined in UserTableViewCell.swift.
// If it's not accessible here due to file structure or access control,
// you might need to move the extension to a separate shared file 
// or redefine it here (less ideal).
// For this example, assume it's accessible.

/* Redundant extension definition - remove if defined elsewhere and accessible
private var imageLoadTaskKey: Void?

extension UIImageView {

    private var imageLoadTask: URLSessionDataTask? {
        get { objc_getAssociatedObject(self, &imageLoadTaskKey) as? URLSessionDataTask }
        set { objc_setAssociatedObject(self, &imageLoadTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func loadImage(from urlString: String?, placeholder: UIImage? = UIImage(systemName: "person.circle.fill")) {
        // ... (Implementation as above)
    }

    func cancelImageLoad() {
        // ... (Implementation as above)
    }
}
*/
