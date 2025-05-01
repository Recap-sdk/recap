import SDWebImage
import UIKit

class FamilyMemberDetailViewController: UIViewController {
    var member: FamilyMember
    private var stackView: UIStackView!
    private var imageView: UIImageView!
    private var scrollView: UIScrollView!
    private var contentView: UIView!

    init(member: FamilyMember) {
        self.member = member
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.updateLayout(for: size)
        })
    }

    private func setLayout() {
        view.backgroundColor = .systemBackground
        navigationItem.title = member.name
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(dismissView))
        closeButton.tintColor = AppColors.iconColor // Change this to your desired color (e.g., .red, .green, or a custom UIColor)
                navigationItem.rightBarButtonItem = closeButton
        
        // Create scroll view for better accessibility
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup constraints for scroll view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Create a much larger image view
        imageView = createEnhancedProfileImageView()
        
        // Add tap gesture to image for zooming feature
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)

        let nameLabel = createNameLabel()
        let relationshipLabel = createRelationshipLabel()
        let phoneStack = createInfoStack(withIcon: "phone.fill", text: member.phone, color: AppColors.iconColor)
        let emailStack = createInfoStack(withIcon: "envelope.fill", text: "\(member.email)", color:AppColors.iconColor)

        let callButton = createCallButton()
        callButton.widthAnchor.constraint(equalToConstant: 250).isActive = true

        let detailsStack = UIStackView(arrangedSubviews: [nameLabel, relationshipLabel, phoneStack, emailStack, callButton])
        detailsStack.axis = .vertical
        detailsStack.spacing = 16
        detailsStack.alignment = .center

        stackView = UIStackView(arrangedSubviews: [imageView, detailsStack])
        stackView.axis = .vertical // Start in portrait mode
        stackView.spacing = 24
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        updateLayout(for: view.bounds.size)
    }

    private func updateLayout(for size: CGSize) {
        if size.width > size.height {
            // Landscape: Horizontal layout
            stackView.axis = .horizontal
            stackView.alignment = .center
            
            // In landscape, make image smaller to fit side by side with details
            imageView.heightAnchor.constraint(equalToConstant: size.height * 0.7).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: size.height * 0.7).isActive = true
        } else {
            // Portrait: Vertical layout
            stackView.axis = .vertical
            stackView.alignment = .center
            
            // In portrait, make image larger
            let imageSize = min(size.width * 0.85, 350)
            imageView.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        }
    }

    private func createEnhancedProfileImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Make image much larger - size will be set in updateLayout
        imageView.layer.cornerRadius = 16  // Less rounded corners for larger image
        
        // Add a subtle border to make image stand out
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = AppColors.primaryButtonColor.cgColor
        
        // Add subtle shadow effect
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowRadius = 6
        imageView.layer.shadowOpacity = 0.2
        
        // Load image from UserDefaults if available, otherwise fetch from URL using SDWebImage
        if let savedImage = UserDefaultsStorageFamilyMember.shared.getFamilyMemberImage(for: member.id) {
            imageView.image = savedImage
        } else {
            imageView.sd_setImage(
                with: URL(string: member.imageURL),
                placeholderImage: UIImage(systemName: "person.circle.fill"),
                options: [.highPriority, .retryFailed],
                completed: { [weak self] (image, error, cacheType, url) in
                    if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                    }
                    // Add high-contrast mode for better visibility if needed
                    if UIAccessibility.isInvertColorsEnabled {
                        imageView.layer.borderWidth = 5
                        imageView.layer.borderColor = UIColor.white.cgColor
                    }
                }
            )
        }
        return imageView
    }

    private func createNameLabel() -> UILabel {
        let label = UILabel()
        label.text = member.name
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)  // Larger font
        label.textAlignment = .center
        return label
    }

    private func createRelationshipLabel() -> UILabel {
        let label = UILabel()
        label.text = member.relationship
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)  // Larger font
        label.textColor = AppColors.iconColor // More vibrant color
        label.textAlignment = .center
        return label
    }

    private func createInfoStack(withIcon iconName: String, text: String, color: UIColor) -> UIStackView {
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = color
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 20)  // Larger font

        let stackView = UIStackView(arrangedSubviews: [iconImageView, label])
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }

    private func createCallButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Call \(member.name)", for: .normal)
        button
            .setTitleColor(
                AppColors.iconColor,
                for: .normal
            )
        button.backgroundColor = AppColors.primaryButtonColor
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        button.addTarget(self, action: #selector(callPhoneNumber), for: .touchUpInside)
        return button
    }
    
    @objc private func handleImageTap() {
        // Create a full-screen image view controller
        let fullScreenVC = FullScreenImageViewController(image: imageView.image, name: member.name)
        present(fullScreenVC, animated: true)
    }

    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func callPhoneNumber() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        guard let url = URL(string: "tel://\(member.phone)"), UIApplication.shared.canOpenURL(url) else {
            // Show a more accessible alert for failure
            let alert = UIAlertController(
                title: "Cannot Make Call",
                message: "This device doesn't support phone calls or the number is invalid.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        UIApplication.shared.open(url)
    }
}

// Full screen image view controller for tapping on images
class FullScreenImageViewController: UIViewController {
    private var imageView: UIImageView!
    private var scrollView: UIScrollView!
    private var nameLabel: UILabel!
    private var personName: String
    
    init(image: UIImage?, name: String) {
        self.personName = name
        super.init(nibName: nil, bundle: nil)
        setupFullScreenView(with: image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFullScreenView(with image: UIImage?) {
        view.backgroundColor = .black
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(dismissFullScreen), for: .touchUpInside)
        
        // Create scroll view for zooming
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        // Create image view
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create name label
        nameLabel = UILabel()
        nameLabel.text = personName
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.layer.shadowColor = UIColor.black.cgColor
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        nameLabel.layer.shadowRadius = 3
        nameLabel.layer.shadowOpacity = 0.7
        
        // Add views to hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(closeButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            nameLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add double tap gesture for zooming
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func dismissFullScreen() {
        dismiss(animated: true)
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            scrollView.setZoomScale(2.0, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
