//
//  LanguageViewController.swift
//  recap
//
//  Created by admin70 on 27/01/25.
//

import UIKit

// Language model to represent available languages
struct Language {
    let name: String
    let nativeName: String
    let code: String
    let flag: String
}

class LanguageViewController: UIViewController {
    
    // MARK: - Properties
    private let languages: [Language] = [
        Language(name: "English", nativeName: "English", code: "en", flag: "🇬🇧"),
        Language(name: "Hindi", nativeName: "हिंदी", code: "hi", flag: "🇮🇳"),
        Language(name: "Bengali", nativeName: "বাংলা", code: "bn", flag: "🇧🇩")
    ]
    
    private var selectedLanguageCode: String {
        get {
            return UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "AppLanguage")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Choose Your Language"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select the language you prefer for the app interface"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var languageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Language"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Add Done button if presented modally
        if presentingViewController != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Done",
                style: .done,
                target: self,
                action: #selector(dismissVC)
            )
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(languageStackView)
        
        // Add language options
        languages.forEach { language in
            let languageButton = createLanguageButton(for: language)
            languageStackView.addArrangedSubview(languageButton)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            languageStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            languageStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            languageStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func createLanguageButton(for language: Language) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure button appearance
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .medium
        configuration.baseBackgroundColor = selectedLanguageCode == language.code ? .systemBlue : .secondarySystemBackground
        configuration.baseForegroundColor = selectedLanguageCode == language.code ? .white : .label
        
        // Create attributed string for button title
        let title = "\(language.flag)  \(language.name)"
        let subtitle = language.nativeName != language.name ? language.nativeName : nil
        
        configuration.title = title
        configuration.subtitle = subtitle
        configuration.titleAlignment = .leading
        
        // Set content padding
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        button.configuration = configuration
        button.tag = languages.firstIndex(where: { $0.code == language.code }) ?? 0
        button.addTarget(self, action: #selector(languageButtonTapped(_:)), for: .touchUpInside)
        
        // Set height constraint
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        
        return button
    }
    
    // MARK: - Actions
    @objc private func languageButtonTapped(_ sender: UIButton) {
        guard let language = languages[safe: sender.tag] else { return }
        
        // Update selected language
        selectedLanguageCode = language.code
        
        // Update UI
        languageStackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let button = view as? UIButton else { return }
            
            var configuration = button.configuration
            let isSelected = index == sender.tag
            configuration?.baseBackgroundColor = isSelected ? .systemBlue : .secondarySystemBackground
            configuration?.baseForegroundColor = isSelected ? .white : .label
            button.configuration = configuration
        }
        
        // Post notification for language change
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        
        // Show success feedback
        showLanguageChangeSuccess(language: language)
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
    
    private func showLanguageChangeSuccess(language: Language) {
        // Create and configure alert
        let alertController = UIAlertController(
            title: "Language Changed",
            message: "The app language has been changed to \(language.name)",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // If presented modally, dismiss after language change
            if self?.presentingViewController != nil {
                self?.dismiss(animated: true)
            }
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview Provider
#Preview {
    UINavigationController(rootViewController: LanguageViewController())
}
