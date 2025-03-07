//
//  HomeViewController.swift
//  recap
//
//  Created by Diptayan Jash on 05/11/24.
//
//

import UIKit

class HomeViewController: UIViewController {
    var analyticsService: CoreAnalyticsService?
    var sessionStartTime: Date?
    private var preloadedArticles: [Article] = []
    
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    
    private let activitiesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Activities"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left  // Align text to the left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal) // Prevent stretching
        return label
    }()

    
    private lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGreen
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        return button
        
        if let verifiedUserDocID = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.verifiedUserDocID) {
            analyticsService = CoreAnalyticsService(verifiedUserDocID: Constants.UserDefaultsKeys.verifiedUserDocID)
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradientBackground()
        setupNavigationBar()
        setupScrollView()
        setupContent()
        prefetchArticles() // Prefetch articles
    }
    private func prefetchArticles() {
        let dataFetch = DataFetch()
        dataFetch.fetchArticles { [weak self] fetchedArticles, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let fetchedArticles = fetchedArticles {
                    self.preloadedArticles = fetchedArticles
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            sessionStartTime = Date()  // Start session tracking
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            if let startTime = sessionStartTime {
                let sessionDuration = Date().timeIntervalSince(startTime) / 60  // Convert to minutes
                analyticsService?.trackTimeSpent(sessionDuration: sessionDuration, isFamily: false)
            }
        }
    
    private func setupNavigationBar() {
        let profileBarButton = UIBarButtonItem(customView: profileButton)
        navigationItem.rightBarButtonItem = profileBarButton
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Recap"
    }
    
    @objc private func profileButtonTapped() {
        let profileVC = ProfileViewController()
        let navController = UINavigationController(rootViewController: profileVC)
        present(navController, animated: true)
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func setupContent() {
        let questionsCard = QuestionsCardView()
        let streaksCard = StreakCardView()
        let letsReadCard = LetsReadCardView()
//        let playGameCard = PlayGameCardView()
        
        // First, add Questions and Streaks cards
        [questionsCard, streaksCard].forEach { item in
            item.translatesAutoresizingMaskIntoConstraints = false
            contentView.addArrangedSubview(item)
            NSLayoutConstraint.activate([
                item.heightAnchor.constraint(equalToConstant: 150)
            ])
        }

        // Add the "Activities" title label
        contentView.addArrangedSubview(activitiesTitleLabel)
        
        // Now, add Let's Read and Play Game cards
        [letsReadCard,
//         playGameCard
        ]
            .forEach { item in
            item.translatesAutoresizingMaskIntoConstraints = false
            contentView.addArrangedSubview(item)
            NSLayoutConstraint.activate([
                item.heightAnchor.constraint(equalToConstant: 150)
            ])
        }
        
        // Add tap gestures
        addTapGesture(to: questionsCard, action: #selector(navigateToQuestions))
        addTapGesture(to: streaksCard, action: #selector(navigateToStreaks))
        addTapGesture(to: letsReadCard, action: #selector(navigateToLetsRead))
//        addTapGesture(to: playGameCard, action: #selector(navigateToPlayGame))
    }

    private func addTapGesture(to view: UIView, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func navigateToQuestions() {
        if let verifiedUserDocID = UserDefaults.standard.string(
            forKey: Constants
                .UserDefaultsKeys.verifiedUserDocID) {
            let questionsVC = PatientQuestionsViewController(verifiedUserDocID: verifiedUserDocID)
            navigationController?.pushViewController(questionsVC, animated: true)
        } else {
            print("Error: verifiedUserDocID not found in UserDefaults.")
        }
    }
    
    @objc private func navigateToStreaks() {
        if let verifiedUserDocID = UserDefaults.standard.string(forKey: "verifiedUserDocID") {
            let streaksVC = StreaksViewController(verifiedUserDocID: verifiedUserDocID)
            navigationController?.pushViewController(streaksVC, animated: true)
        } else {
            print("Error: verifiedUserDocID not found in UserDefaults.")
        }
    }
    
    @objc private func navigateToLetsRead() {
        let articlesVC = ArticleTableViewController(preloadedArticles: preloadedArticles)
        navigationController?.pushViewController(articlesVC, animated: true)
    }
    
    @objc private func navigateToPlayGame() {
        let playGameVC = PlayGameViewController()
        navigationController?.pushViewController(playGameVC, animated: true)
    }
    
    private func applyGradientBackground() {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                UIColor(red: 0.69, green: 0.88, blue: 0.88, alpha: 1.0).cgColor,
                UIColor(red: 0.94, green: 0.74, blue: 0.80, alpha: 1.0).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
}


#Preview()
{
    HomeViewController()
}
