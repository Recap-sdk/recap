//
//  PrivacyViewController.swift
//  recap
//
//  Created by admin70 on 27/01/25.
//

import SafariServices
import UIKit
import WebKit

class PrivacyViewController: UIViewController {

    // URL to the privacy policy
    private let privacyPolicyURL = URL(string: "https://recap.djdiptayan.in/privacyPolicy")!

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
        label.text = "Fetching last update..."  // Will be updated when policy loads
        label.textColor = AppColors.secondaryButtonTextColor.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences

        // Inject CSS early to prevent layout jumps
        let css = """
                body {
                    font-family: -apple-system, San Francisco, sans-serif;
                    padding: 0 16px !important;
                    margin: 0 !important;
                    background-color: transparent;
                }
                main {
                    padding-top: 0 !important;
                    margin-top: 0 !important;
                }
                /* Hide elements immediately */
                nav, header, footer,
                .text-center.mb-12, .mt-4.text-xl, p.mt-4.text-xl {
                    display: none !important;
                }
            """

        let script = WKUserScript(
            source:
                "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(script)

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.showsVerticalScrollIndicator = true
        return webView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = AppColors.iconColor
        return indicator
    }()

    private let fallbackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        return stackView
    }()

    private let lastUpdatedLabel: UILabel = {
        let label = UILabel()
        label.text = ""  // Empty since we moved this to subtitle
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true  // Hide this label
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPrivacyPolicy()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Privacy Policy"

        // Add view to open in browser
        let openInSafariButton = UIBarButtonItem(
            image: UIImage(systemName: "safari"),
            style: .plain,
            target: self,
            action: #selector(openInSafari)
        )
        navigationItem.rightBarButtonItem = openInSafariButton

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        headerView.addSubview(iconImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)

        // Add the web view
        contentView.addSubview(webView)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(fallbackView)
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
            subtitleLabel.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor, constant: -20),

            // Reduced gap from 10 to -5 (slight overlap to eliminate visual gap)
            webView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.heightAnchor.constraint(greaterThanOrEqualToConstant: 400),

            activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(
                equalTo: webView.centerYAnchor, constant: -40),

            fallbackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5),
            fallbackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fallbackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),

            lastUpdatedLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 24),
            lastUpdatedLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            lastUpdatedLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),
            lastUpdatedLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }

    private func loadPrivacyPolicy() {
        // Show activity indicator while loading
        activityIndicator.startAnimating()

        // Set up webView delegate to handle load events
        webView.navigationDelegate = self

        // Load privacy policy from URL
        let request = URLRequest(url: privacyPolicyURL)
        webView.load(request)
    }

    private func setupFallbackContent() {
        // In case the web content fails to load, show a fallback view with key privacy points
        fallbackView.isHidden = false
        webView.isHidden = true

        // Clear any existing views
        fallbackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add sections with privacy information
        let sections = [
            (
                "Personal Information",
                "We collect your email address, name, and profile information to provide you with a personalized experience."
            ),
            (
                "Usage Data",
                "We collect app interaction data and device information to improve our services."
            ),
            (
                "Analytics",
                "We use analytics for Firebase to enhance app performance and user experience."
            ),
            (
                "Data Protection",
                "Your data is securely stored using industry-standard encryption and security measures."
            ),
            (
                "User Rights",
                "You have full control over your data. Access, modify, or delete your information at any time."
            ),
            ("Contact Us", "Questions about your privacy? Reach out to us at recapsdk@gmail.com"),
        ]

        sections.forEach { title, content in
            let sectionView = createSectionView(title: title, content: content)
            fallbackView.addArrangedSubview(sectionView)
        }

        // Add a button to try loading from the web again
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Try Loading Online Version", for: .normal)
        retryButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        retryButton.addTarget(self, action: #selector(retryWebLoad), for: .touchUpInside)
        fallbackView.addArrangedSubview(retryButton)
    }

    @objc private func retryWebLoad() {
        fallbackView.isHidden = true
        webView.isHidden = false
        loadPrivacyPolicy()
    }

    @objc private func openInSafari() {
        let safariVC = SFSafariViewController(url: privacyPolicyURL)
        present(safariVC, animated: true)
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
            titleLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -16),

            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor, constant: -16),
        ])

        return containerView
    }
}

// MARK: - WKNavigationDelegate
extension PrivacyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Hide activity indicator when content loads
        activityIndicator.stopAnimating()

        // Extract the last updated date from the webpage
        let dateExtractionScript = """
                (function() {
                    // Try to find the date in various elements where it might be
                    var dateText = "";
                    
                    // Look for the specific format in the page
                    var dateElement = document.querySelector('.mt-4.text-xl');
                    if (dateElement) {
                        dateText = dateElement.textContent.trim();
                    }
                    
                    // If not found, try other selectors
                    if (!dateText) {
                        var elements = document.querySelectorAll('p');
                        for (var i = 0; i < elements.length; i++) {
                            if (elements[i].textContent.includes('Last updated:')) {
                                dateText = elements[i].textContent.trim();
                                break;
                            }
                        }
                    }
                    
                    // Return the found date text or default
                    return dateText || "Last updated information not available";
                })();
            """

        webView.evaluateJavaScript(dateExtractionScript) { [weak self] (result, error) in
            guard let self = self, let dateText = result as? String else { return }

            // Extract just the date part if the format is "Last updated: May 31, 2025"
            var displayText = dateText
            if let range = dateText.range(of: "Last updated:") {
                displayText = String(dateText[range.upperBound...]).trimmingCharacters(
                    in: .whitespacesAndNewlines)
            }

            // Update the subtitle label on the main thread
            DispatchQueue.main.async {
                if displayText.isEmpty || displayText == "Last updated information not available" {
                    self.subtitleLabel.text = "Your privacy is our priority"
                } else {
                    self.subtitleLabel.text = "Last updated: \(displayText)"
                }
            }
        }

        // Enhanced CSS injection with better spacing control
        let css = """
            body {
                font-family: -apple-system, San Francisco, sans-serif;
                padding: 8px 16px 0 16px !important;
                margin: 0 !important;
                color: \(isDarkMode() ? "#FFFFFF" : "#000000");
                background-color: transparent;
            }
            h1, h2, h3 { 
                color: \(isDarkMode() ? "#FFFFFF" : "#000000");
                margin-top: 0 !important;
            }
            h1:first-of-type {
                margin-top: 0 !important;
                padding-top: 8px !important;
            }
            a {
                color: #0066CC;
            }
            /* Hide navigation bar */
            nav, header {
                display: none !important;
            }
            /* Hide footer */
            footer {
                display: none !important;
            }
            /* Remove top spacing from main content */
            main {
                padding-top: 0 !important;
                margin-top: 0 !important;
            }
            /* Hide last updated element and title container */
            .text-center.mb-12, .mt-4.text-xl, p.mt-4.text-xl {
                display: none !important;
            }
            /* Make primary h1 more visible and remove extra spacing */
            main h1:first-of-type {
                font-size: 2.5rem !important;
                margin-bottom: 1.5rem !important;
                margin-top: 0 !important;
                padding-top: 0 !important;
                text-align: center;
            }
            """

        let script =
            "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(script)

        // Use JavaScript to remove navigation and footer elements directly for better reliability
        let removeElementsScript = """
                // Remove navigation
                var navElements = document.querySelectorAll('nav');
                navElements.forEach(function(nav) { nav.parentNode.removeChild(nav); });
                
                // Remove header
                var headerElements = document.querySelectorAll('header');
                headerElements.forEach(function(header) { header.parentNode.removeChild(header); });
                
                // Remove footer
                var footerElements = document.querySelectorAll('footer');
                footerElements.forEach(function(footer) { footer.parentNode.removeChild(footer); });
                
                // Remove the title container with the date
                var titleContainers = document.querySelectorAll('.text-center.mb-12');
                titleContainers.forEach(function(container) { container.parentNode.removeChild(container); });
                
                // Remove any standalone date elements
                var dateElements = document.querySelectorAll('.mt-4.text-xl, p.mt-4.text-xl');
                dateElements.forEach(function(element) { element.parentNode.removeChild(element); });
                
                // Reset body and main margins/padding
                document.body.style.margin = '0';
                document.body.style.paddingTop = '8px';
                var mainElement = document.querySelector('main');
                if (mainElement) {
                    mainElement.style.marginTop = '0';
                    mainElement.style.paddingTop = '0';
                }
            """
        webView.evaluateJavaScript(removeElementsScript)

        // Adjust web view height to content height
        webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] (height, error) in
            guard let height = height as? CGFloat, let self = self else { return }
            let extraSpace: CGFloat = 2  // Reduced extra space

            self.webView.heightAnchor.constraint(equalToConstant: height + extraSpace).isActive =
                true
            self.view.layoutIfNeeded()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleWebViewError()
    }

    func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        handleWebViewError()
    }

    private func handleWebViewError() {
        activityIndicator.stopAnimating()
        subtitleLabel.text = "Your privacy is our priority"
        setupFallbackContent()
    }

    private func isDarkMode() -> Bool {
        return self.traitCollection.userInterfaceStyle == .dark
    }
}

#Preview("Privacy Policy") {
    let vc = PrivacyViewController()
    return UINavigationController(rootViewController: vc)
}
