//
//  OnboardingViewController.swift
//  recap
//
//  Created by Diptayan Jash on 11/02/25.
//
import Foundation
import UIKit

// MARK: - OnboardingPage Model
struct OnboardingFeature {
    let image: String  // SF Symbol name
    let title: String
    let description: String
}

// MARK: - OnboardingViewController
class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    private let features: [OnboardingFeature] = [
        OnboardingFeature(
            image: "brain.head.profile",
            title: "Memory Companion",
            description: "Your personal assistant for maintaining and improving memory health"
        ),
        OnboardingFeature(
            image: "list.clipboard",
            title: "Daily Questions",
            description: "Answer routine questions and get them verified by family members"
        ),
        OnboardingFeature(
            image: "chart.line.uptrend.xyaxis",
            title: "Track Progress",
            description: "Monitor memory improvements with detailed reports and analytics"
        ),
        OnboardingFeature(
            image: "gamecontroller",
            title: "Memory Games",
            description: "Engage with fun memory exercises and cognitive games"
        )
    ]
    
    // MARK: - UI Components
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 28
        stack.alignment = .center
        return stack
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to Recap"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 36, bottom: 14, trailing: 36)
        configuration.title = "Get Started"
        configuration.baseBackgroundColor = AppColors.primaryButtonColor // Change to your desired color
        configuration.baseForegroundColor = AppColors.primaryButtonTextColor // Change text color if needed
        
        button.configuration = configuration
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        isModalInPresentation = true
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(mainStack)
        
        mainStack.addArrangedSubview(welcomeLabel)
        
        // Add feature views to stack
        features.forEach { feature in
            let featureView = createFeatureView(feature)
            mainStack.addArrangedSubview(featureView)
            
            NSLayoutConstraint.activate([
                featureView.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 24),
                featureView.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -24)
            ])
        }
        
        mainStack.addArrangedSubview(getStartedButton)
        
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    private func createFeatureView(_ feature: OnboardingFeature) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppColors.iconColor
        imageView.image = UIImage(systemName: feature.image)?.applyingSymbolConfiguration(.init(pointSize: 32))
        
        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let titleLabel = UILabel()
        titleLabel.text = feature.title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = feature.description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(descriptionLabel)
        
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(textStack)
        
        containerView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            
            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
    
    // MARK: - Actions
    @objc private func getStartedTapped() {
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
        dismiss(animated: true) {
            if let rootVC = UIApplication.shared.windows.first?.rootViewController as? launchScreenViewController {
                rootVC.transitionToMainScreen()
            }
        }
    }
}

#Preview {
    OnboardingViewController()
}
