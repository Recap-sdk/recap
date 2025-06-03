//
//  CitationsViewController.swift
//  recap
//
//  Created on 03/06/25.
//

import SafariServices
import UIKit

class CitationsViewController: UIViewController {

    // Property to store preloaded citations
    var preloadedCitations: [Citation]?

    // MARK: - UI Elements

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Medical Information Citations"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "All medical information in this app is based on the following sources:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let citationsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.text =
            "Medical Disclaimer: The information provided is for educational purposes only and is not intended as medical advice. Always consult with a healthcare professional before making any medical decisions."
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        populateCitations()
    }

    // MARK: - Setup

    private func setupView() {
        title = "Citations"
        view.backgroundColor = .systemBackground

        // Add scroll view to view
        view.addSubview(scrollView)

        // Add content view to scroll view
        scrollView.addSubview(contentView)

        // Add elements to content view
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(citationsStackView)
        contentView.addSubview(disclaimerLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Title Label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),

            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),

            // Citations Stack View
            citationsStackView.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor, constant: 24),
            citationsStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            citationsStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),

            // Disclaimer Label
            disclaimerLabel.topAnchor.constraint(
                equalTo: citationsStackView.bottomAnchor, constant: 32),
            disclaimerLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            disclaimerLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),
            disclaimerLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -32),
        ])
    }

    // MARK: - Data Population

    // Use citations manager to get all citations
    private let citationsManager = MedicalCitationsManager.shared

    private func populateCitations() {
        // Use preloaded citations if available, otherwise use from manager
        let citations = preloadedCitations ?? citationsManager.allCitations

        if citations.isEmpty {
            // If still empty, show a loading state and try to refresh
            let loadingView = UIView()
            loadingView.translatesAutoresizingMaskIntoConstraints = false

            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false

            let loadingLabel = UILabel()
            loadingLabel.text = "Loading citations..."
            loadingLabel.textAlignment = .center
            loadingLabel.font = UIFont.systemFont(ofSize: 16)
            loadingLabel.translatesAutoresizingMaskIntoConstraints = false

            loadingView.addSubview(activityIndicator)
            loadingView.addSubview(loadingLabel)

            NSLayoutConstraint.activate([
                activityIndicator.topAnchor.constraint(
                    equalTo: loadingView.topAnchor, constant: 20),
                activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),

                loadingLabel.topAnchor.constraint(
                    equalTo: activityIndicator.bottomAnchor, constant: 10),
                loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
                loadingLabel.bottomAnchor.constraint(
                    equalTo: loadingView.bottomAnchor, constant: -20),
            ])

            citationsStackView.addArrangedSubview(loadingView)

            citationsManager.refreshCitations { [weak self] success in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    // Clear loading indicator
                    self.citationsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

                    // Add refreshed citations
                    for citation in self.citationsManager.allCitations {
                        let citationView = self.createCitationView(for: citation)
                        self.citationsStackView.addArrangedSubview(citationView)
                    }
                }
            }
        } else {
            // Add all citations without segregation
            for citation in citations {
                let citationView = createCitationView(for: citation)
                citationsStackView.addArrangedSubview(citationView)
            }
        }

        // Set disclaimer text from the manager
        disclaimerLabel.text = citationsManager.getMedicalDisclaimer()
    }

    private func createCitationView(for citation: Citation) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let citationLabel = UILabel()
        citationLabel.text = citation.formattedCitation
        citationLabel.font = UIFont.systemFont(ofSize: 14)
        citationLabel.numberOfLines = 0
        citationLabel.translatesAutoresizingMaskIntoConstraints = false

        let sourceButton = UIButton(type: .system)
        sourceButton.setTitle("View Source", for: .normal)
        sourceButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sourceButton.translatesAutoresizingMaskIntoConstraints = false

        if let url = citation.url {
            sourceButton.tag = citationsStackView.arrangedSubviews.count
            sourceButton.addTarget(self, action: #selector(openSourceURL(_:)), for: .touchUpInside)
            // Store URL in associated object
            objc_setAssociatedObject(
                sourceButton, UnsafeRawPointer(bitPattern: 1)!, url,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            sourceButton.isEnabled = false
        }

        containerView.addSubview(citationLabel)
        containerView.addSubview(sourceButton)

        NSLayoutConstraint.activate([
            citationLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            citationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            citationLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -100),

            sourceButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            sourceButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            sourceButton.widthAnchor.constraint(equalToConstant: 100),

            citationLabel.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor, constant: -8),
        ])

        return containerView
    }

    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])

        return separator
    }

    // MARK: - Actions

    @objc private func openSourceURL(_ sender: UIButton) {
        guard let url = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: 1)!) as? URL
        else {
            return
        }

        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}
