//
//  AboutAppViewController.swift
//  recap
//
//  Created by khushi on 27/01/25.
//

import UIKit

class AboutAppViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.secondaryButtonColor
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        return view
    }()
    
    private let appIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "recapLogo")
        imageView.tintColor = AppColors.secondaryButtonColor
        imageView.layer.cornerRadius = 30
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizationManager.shared.localizedString(for: "Recap")
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = AppColors.primaryButtonTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            label.text = "Version \(version)"
        } else {
            label.text = "Version Not Available"
        }
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = AppColors.secondaryButtonTextColor.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = """
        Pre-clinical Alzheimer patients face memory recall challenges, leading to further degradation of memory over time.

        Addressing Alzheimer's memory recall is vital for reducing cognitive decline. It matters because better monitoring can enhance quality of life for millions worldwide.
        """
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let featuresSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        return view
    }()
    
    private let featuresTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Key Features"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let featuresStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let features: [(icon: String, title: String, description: String)] = [
        ("calendar.badge.clock", "Routine Questions", "Daily questions verified by family members"),
        ("book.fill", "Supporting Resources", "Personalized resources for lifestyle improvement"),
        ("brain", "Rapid Memory Check", "Monthly assessment with detailed scoring"),
        ("chart.bar.fill", "Progress Reports", "Comprehensive progress tracking with graphs"),
        ("gamecontroller.fill", "Gamification", "Age-appropriate games and achievements"),
        ("person.2.fill", "Family View", "Manage family details and contacts")
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
                   self,
                   selector: #selector(languageChanged),
                   name: Notification.Name("LanguageChanged"),
                   object: nil
               )
        
        setupUI()
        setupNavigationBar()
        animateContent()
    }
    @objc private func languageChanged() {
           // Update all text in the view controller
           titleLabel.text = LocalizationManager.shared.localizedString(for: "about_title")
           descriptionLabel.text = LocalizationManager.shared.localizedString(for: "about_description")
           featuresTitleLabel.text = LocalizationManager.shared.localizedString(for: "features_title")
           // Update any other text elements...
       }
    deinit {
            NotificationCenter.default.removeObserver(self)
        }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.title = "About"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(appIconImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(versionLabel)
        
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(featuresSectionView)
        featuresSectionView.addSubview(featuresTitleLabel)
        featuresSectionView.addSubview(featuresStackView)
        
        setupFeatures()
        setupConstraints()
    }
    
    private func setupFeatures() {
        features.forEach { feature in
            let featureView = createFeatureView(
                icon: feature.icon,
                title: feature.title,
                description: feature.description
            )
            featuresStackView.addArrangedSubview(featureView)
        }
    }
    
    private func createFeatureView(icon: String, title: String, description: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImage = UIImageView()
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.image = UIImage(systemName: icon)
        iconImage.tintColor = AppColors.iconColor
        iconImage.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        container.addSubview(iconImage)
        container.addSubview(titleLabel)
        container.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            iconImage.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconImage.topAnchor.constraint(equalTo: container.topAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 24),
            iconImage.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 260),
            
            appIconImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            appIconImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            appIconImageView.widthAnchor.constraint(equalToConstant: 80),
            appIconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: appIconImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            versionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            versionLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            featuresSectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            featuresSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            featuresSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            featuresSectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            featuresTitleLabel.topAnchor.constraint(equalTo: featuresSectionView.topAnchor, constant: 16),
            featuresTitleLabel.leadingAnchor.constraint(equalTo: featuresSectionView.leadingAnchor, constant: 16),
            featuresTitleLabel.trailingAnchor.constraint(equalTo: featuresSectionView.trailingAnchor, constant: -16),
            
            featuresStackView.topAnchor.constraint(equalTo: featuresTitleLabel.bottomAnchor, constant: 16),
            featuresStackView.leadingAnchor.constraint(equalTo: featuresSectionView.leadingAnchor, constant: 16),
            featuresStackView.trailingAnchor.constraint(equalTo: featuresSectionView.trailingAnchor, constant: -16),
            featuresStackView.bottomAnchor.constraint(equalTo: featuresSectionView.bottomAnchor, constant: -16)
        ])
    }
    
    private func animateContent() {
        let views = [headerView, descriptionLabel, featuresSectionView]
        
        views.enumerated().forEach { index, view in
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 20)
            
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.2,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut
            ) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }
}

#Preview {
    AboutAppViewController()
}
