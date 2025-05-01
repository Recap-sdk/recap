//
//  ArticleTableViewCell.swift
//  Recap
//
//  Created by khushi on 22/03/25.
//

import UIKit
import SafariServices

class ArticleDetailViewController: UIViewController {
    
    private let article: Article

    // MARK: - UI Elements

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 0 // Full width image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let metadataView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let readTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let readMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = AppColors.iconColor
        button.setTitle("Read Full Article", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization

    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        configureWithArticle()
        setupActions()
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        
        // Add scroll view to main view
        view.addSubview(scrollView)
        
        // Add content view to scroll view
        scrollView.addSubview(contentView)
        
        // Add elements to content view
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(metadataView)
        metadataView.addSubview(authorLabel)
        metadataView.addSubview(readTimeLabel)
        contentView.addSubview(dividerView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(readMoreButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Image View - Full width at the top
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 250),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Metadata View
            metadataView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            metadataView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            metadataView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            metadataView.heightAnchor.constraint(equalToConstant: 20),
            
            // Author Label
            authorLabel.leadingAnchor.constraint(equalTo: metadataView.leadingAnchor),
            authorLabel.centerYAnchor.constraint(equalTo: metadataView.centerYAnchor),
            
            // Read Time Label
            readTimeLabel.trailingAnchor.constraint(equalTo: metadataView.trailingAnchor),
            readTimeLabel.centerYAnchor.constraint(equalTo: metadataView.centerYAnchor),
            
            // Divider
            dividerView.topAnchor.constraint(equalTo: metadataView.bottomAnchor, constant: 16),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            // Content Label
            contentLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Read More Button
            readMoreButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 32),
            readMoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            readMoreButton.widthAnchor.constraint(equalToConstant: 200),
            readMoreButton.heightAnchor.constraint(equalToConstant: 50),
            readMoreButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func setupActions() {
        readMoreButton.addTarget(self, action: #selector(openLink), for: .touchUpInside)
    }

    // MARK: - Configuration

    private func configureWithArticle() {
        title = ""  // Clear the title to focus on the content
        imageView.image = article.image
        titleLabel.text = article.title
        authorLabel.text = "By \(article.author)"
        contentLabel.text = article.content
        readTimeLabel.text = calculateReadTime(for: article.content)
    }

    // MARK: - Actions

    @objc private func openLink() {
        if let url = URL(string: article.link) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }

    // MARK: - Helper Methods

    private func calculateReadTime(for text: String) -> String {
        // Average reading speed: 200-250 words per minute
        let wordsPerMinute = 150
        
        // Count words in the text
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        let wordCount = words.filter { !$0.isEmpty }.count
        
        // Calculate reading time in minutes
        let readTimeMinutes = max(1, Int(ceil(Double(wordCount) / Double(wordsPerMinute))))
        
        if readTimeMinutes == 1 {
            return "1 min read"
        } else {
            return "\(readTimeMinutes) mins read"
        }
    }
}
