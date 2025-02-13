//
//  FamilyViewController.swift
//  Recap
//
//  Created by admin70 on 04/11/24.
//

import UIKit
import SwiftUI

class FamilyViewController: UIViewController {
    var analyticsService: CoreAnalyticsService?
    var sessionStartTime: Date?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()


    private lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGreen
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        return button
    }()
//    let dailyQuestionsVC = DailyQuestionsViewController()
    
    private var maxStreak: Int = 15
    private var currentStreak: Int = 7
    private var activeDays: Int = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        applyGradientBackground()
        
        if let verifiedUserDocID = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.verifiedUserDocID) {
            analyticsService = CoreAnalyticsService(verifiedUserDocID: Constants.UserDefaultsKeys.verifiedUserDocID)
        }
        
//        dailyQuestionsVC.addQuestionsToFirestore()
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
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground

        // ScrollView and ContentView Setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        let streakCard = StreakCardView()
               streakCard.onTap = { [weak self] in
                   if let verifiedUserDocID = UserDefaults.standard.string(forKey: "verifiedUserDocID") {
                       let streaksVC = StreaksViewController(verifiedUserDocID: verifiedUserDocID)
                       self?.navigationController?.pushViewController(streaksVC, animated: true)
                   } else {
                       print("Error: verifiedUserDocID not found in UserDefaults.")
                   }
               }
        streakCard.updateStreakStats(maxStreak: maxStreak, currentStreak: currentStreak, activeDays: activeDays)
        let dailyQuestionCard = DailyQuestionCardView()
        dailyQuestionCard.navigateToDetail = {
            if let verifiedUserDocID = UserDefaults.standard.string(forKey: "verifiedUserDocID") {
                let detailVC = DailyQuestionDetailViewController(verifiedUserDocID: verifiedUserDocID)
                self.navigationController?.pushViewController(detailVC, animated: true)
            } else {
                print("Error: verifiedUserDocID not found in UserDefaults.")
            }
        }

//        let dailyQuestionCard = DailyQuestionCardView()
//        dailyQuestionCard.navigateToDetail = {
//            if let verifiedUserDocID = UserDefaults.standard.string(forKey: "verifiedUserDocID") {
//                // Create an instance of PatientQuestionsViewController
//                let patientQuestionsVC = PatientQuestionsViewController(verifiedUserDocID: verifiedUserDocID)
//                
//                // Navigate to the PatientQuestionsViewController
//                self.navigationController?.pushViewController(patientQuestionsVC, animated: true)
//            } else {
//                print("Error: verifiedUserDocID not found in UserDefaults.")
//            }
//        }

       
        // Daily Question, Streak, and Trends Cards
//        let streakCard = StreakCardView()
//        streakCard.onTap = { [weak self] in
//            if let verifiedUserDocID = UserDefaults.standard.string(forKey: "verifiedUserDocID") {
//                let streaksVC = StreaksViewController(verifiedUserDocID: verifiedUserDocID)
//                self?.navigationController?.pushViewController(streaksVC, animated: true)
//            } else {
//                print("Error: verifiedUserDocID not found in UserDefaults.")
//            }
//        }

        
        let trendsCard = TrendsCardView()
        trendsCard.onInsightsTap = { [weak self] tag in
            var detailViewController: UIViewController?
            switch tag {
            case 1:
                let swiftUIView = ImmediateReportDetailViewController()
                detailViewController = UIHostingController(rootView: swiftUIView)
            case 2:
                let recentReportDetailView = RecentReportDetailViewController(data: recentMemoryData)
                detailViewController = UIHostingController(rootView: recentReportDetailView)
            case 3:
                let remoteReportDetailView = RemoteReportDetailViewController(monthlyData: novemberReports)
                detailViewController = UIHostingController(rootView: remoteReportDetailView)
            default:
                return
            }
            if let detailVC = detailViewController {
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
        }

        // Vertical StackView for Daily Question and Streak
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
        
        // Constraints
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

    @objc private func profileButtonTapped() {
        let profileVC = FamilyProfileViewController()
        let navController = UINavigationController(rootViewController: profileVC)
        present(navController, animated: true)
    }
}
#Preview
{FamilyViewController()}
