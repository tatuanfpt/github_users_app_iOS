import UIKit
// import Kingfisher // Removed Kingfisher import

class UserTableViewCell: UITableViewCell {

    static let reuseIdentifier = "UserTableViewCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground // Adapts to light/dark mode
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30 // Half of the width/height
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray // Placeholder color
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var currentAvatarUrlString: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .clear // Make content view clear
        backgroundColor = .clear // Make cell background clear
        selectionStyle = .none // No selection highlight

        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(urlLabel)

        let textStackView = UIStackView(arrangedSubviews: [nameLabel, urlLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textStackView)

        // Add padding around the container view
        let padding: CGFloat = 8
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding / 2),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding / 2),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),

            textStackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    func configure(with user: GitHubUser) {
        nameLabel.text = user.login
        urlLabel.text = user.htmlUrl.absoluteString
        
        // Set placeholder initially
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .gray
        
        let urlString = user.avatarUrl.absoluteString
        currentAvatarUrlString = urlString

        // Load image asynchronously
        loadImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                // Only set image if the cell hasn't been reused for a different URL
                if self?.currentAvatarUrlString == urlString {
                    if let loadedImage = image {
                        self?.avatarImageView.image = loadedImage
                        self?.avatarImageView.tintColor = nil // Clear tint if image loaded
                    } else {
                        // Keep placeholder if loading failed
                        self?.avatarImageView.image = UIImage(systemName: "person.circle.fill")
                        self?.avatarImageView.tintColor = .gray
                    }
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset image and URL tracking
        avatarImageView.image = nil 
        currentAvatarUrlString = nil
        nameLabel.text = nil
        urlLabel.text = nil
    }
    
    // --- Image Loading Helper ---
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        // Use shared URLSession - consider a shared instance with caching if needed
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


