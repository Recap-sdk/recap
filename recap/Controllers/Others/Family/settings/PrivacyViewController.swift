//
//  PrivacyViewController.swift
//  recap
//
//  Created by admin70 on 27/01/25.
//

import UIKit

class PrivacyViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.secondaryButtonColor
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppColors.iconColor
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
        imageView.image = UIImage(systemName: "shield.checkerboard", withConfiguration: config)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Privacy Policy"
        label.textColor = AppColors.primaryButtonTextColor
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your privacy is our priority"
        label.textColor = AppColors.secondaryButtonTextColor.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sectionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let lastUpdatedLabel: UILabel = {
        let label = UILabel()
        label.text = "Last updated: February 19, 2025"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSections()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Privacy Policy"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        headerView.addSubview(iconImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        contentView.addSubview(sectionsStackView)
        contentView.addSubview(lastUpdatedLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
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
            
            iconImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            sectionsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            sectionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sectionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            lastUpdatedLabel.topAnchor.constraint(equalTo: sectionsStackView.bottomAnchor, constant: 24),
            lastUpdatedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lastUpdatedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            lastUpdatedLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func createSectionView(title: String, content: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = .systemFont(ofSize: 15)
        contentLabel.textColor = .secondaryLabel
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        return containerView
    }
    
    private func setupSections() {
        let sections = [
            ("Personal Information", "We collect your email address, name, and profile information to provide you with a personalized experience."),
            ("Usage Data", "We collect app interaction data and device information to improve our services."),
            ("Analytics", "We use Google Analytics for Firebase to enhance app performance and user experience."),
            ("Data Protection", "Your data is securely stored using industry-standard encryption and security measures."),
            ("User Rights", "You have full control over your data. Access, modify, or delete your information at any time."),
            ("Contact Us", "Questions about your privacy? Reach out to us at privacy@ourapp.com")
        ]
        
        sections.forEach { title, content in
            let sectionView = createSectionView(title: title, content: content)
            sectionsStackView.addArrangedSubview(sectionView)
        }
    }
}

#Preview("Privacy Policy") {
    let vc = PrivacyViewController()
    return UINavigationController(rootViewController: vc)
}
