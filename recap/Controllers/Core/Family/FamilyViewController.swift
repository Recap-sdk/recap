//
//  FamilyViewController.swift
//  Recap
//
//  Created by khushi on 04/11/24.
//

import UIKit
import SwiftUI

class FamilyViewController: UIViewController {
    var analyticsService: CoreAnalyticsService?
    var sessionStartTime: Date?
    private var verifiedUserDocID: String?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = AppColors.iconColor
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        view.applyGradientBackground()
        analyticsService = CoreAnalyticsService()
        
        guard let verifiedUserDocID = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.verifiedUserDocID) else {
              print("❌ Error: verifiedUserDocID not found in UserDefaults.")
              return
          }
        self.verifiedUserDocID = verifiedUserDocID
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionStartTime = Date()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let startTime = sessionStartTime {
            let sessionDuration = Date().timeIntervalSince(startTime) / 60
            analyticsService?.trackTimeSpent(sessionDuration: sessionDuration, isFamily: true)
        }
    }

    private func setupNavigationBar() {
        let profileBarButton = UIBarButtonItem(customView: profileButton)
        navigationItem.rightBarButtonItem = profileBarButton
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Family"
        profileBarButton.tintColor = AppColors.iconColor
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)

        let streakCard = StreakCardView()
            streakCard.onTap = { [weak self] in
                let verifiedUserDocID = self?.verifiedUserDocID
                let streaksVC = StreaksViewController(verifiedUserDocID: verifiedUserDocID!)
                self?.navigationController?.pushViewController(streaksVC, animated: true)
            }

        let dailyQuestionCard = DailyQuestionCardView()
            dailyQuestionCard.navigateToDetail = { [weak self] in
                let verifiedUserDocID = self?.verifiedUserDocID
                let detailVC = DailyQuestionDetailViewController(verifiedUserDocID: verifiedUserDocID!)
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }


        // Trends Card Setup with dynamic verifiedUserDocID
        guard let verifiedUserDocID = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.verifiedUserDocID) else {
            print("Error: verifiedUserDocID not found in UserDefaults.")
            return
        }
        
        let trendsCard = TrendsCardView(frame: CGRect(x: 0, y: 0, width: 200, height: 100), verifiedUserDocID: verifiedUserDocID)
        trendsCard.onInsightsTap = { [weak self] tag in
            var detailViewController: UIViewController?
            switch tag {
                case 1:
                    let swiftUIView = ImmediateReportDetailViewController(verifiedUserDocID: verifiedUserDocID)
                    detailViewController = UIHostingController(rootView: swiftUIView)
                case 2:
                    let recentReportDetailView = RecentReportDetailViewController(verifiedUserDocID: verifiedUserDocID)
                    detailViewController = UIHostingController(rootView: recentReportDetailView)
                case 3:
                    let remoteReportDetailView = RemoteReportDetailViewController(verifiedUserDocID: verifiedUserDocID)
                    detailViewController = UIHostingController(rootView: remoteReportDetailView)
                default:
                    return
            }
            
            if let detailVC = detailViewController {
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
        }

        let dailyAndStreakStackView = UIStackView(arrangedSubviews: [dailyQuestionCard, streakCard])
            dailyAndStreakStackView.axis = .vertical
            dailyAndStreakStackView.spacing = 16
            dailyAndStreakStackView.translatesAutoresizingMaskIntoConstraints = false

        let trendsCardStackView = UIStackView(arrangedSubviews: [trendsCard])
            trendsCardStackView.axis = .horizontal
            trendsCardStackView.spacing = 16
            trendsCardStackView.distribution = .fillEqually
            trendsCardStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(dailyAndStreakStackView)
        contentView.addSubview(trendsCardStackView)

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

            dailyAndStreakStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            dailyAndStreakStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dailyAndStreakStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            trendsCardStackView.topAnchor.constraint(equalTo: dailyAndStreakStackView.bottomAnchor, constant: 16),
            trendsCardStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trendsCardStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trendsCardStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            ])
        }
              
    @objc private func profileButtonTapped() {
        let profileVC = FamilyProfileViewController()
        let navController = UINavigationController(rootViewController: profileVC)
        present(navController, animated: true)
    }
}

#Preview {
    FamilyViewController()
}
