//
//  StreaksViewController+Setup.swift
//  recap
//
//  Created by user@47 on 16/01/25.
//

import UIKit

extension StreaksViewController {
    // MARK: - Setup Gradient Background
    func setupGradientBackground() {
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

    // MARK: - Setup Profile View
    func setupProfileView() {
        let profileImageView = UIImageView(image: UIImage(named: "profile_placeholder"))
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            profileImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Setup Navigation Bar
    func setupNavBar() {
        title = "Streaks"
    }

    // MARK: - Setup Streak Stats View
    func setupStreakStatsView() {
        streakStatsView.backgroundColor = .white
        streakStatsView.layer.cornerRadius = 12
        streakStatsView.layer.shadowColor = UIColor.black.cgColor
        streakStatsView.layer.shadowOpacity = 0.1
        streakStatsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        streakStatsView.layer.shadowRadius = 4
        streakStatsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(streakStatsView)

        let streakStatsStackView = UIStackView()
        streakStatsStackView.axis = .horizontal
        streakStatsStackView.distribution = .fillEqually
        streakStatsStackView.alignment = .center
        streakStatsStackView.translatesAutoresizingMaskIntoConstraints = false

        let maxStreakView = createStatView(title: "Max Streak", value: "9")
        let currentStreakView = createStatView(title: "Current Streak", value: "5")
        let activeDaysView = createStatView(title: "Active Days", value: "18")

        streakStatsStackView.addArrangedSubview(maxStreakView)
        streakStatsStackView.addArrangedSubview(currentStreakView)
        streakStatsStackView.addArrangedSubview(activeDaysView)

        streakStatsView.addSubview(streakStatsStackView)

        NSLayoutConstraint.activate([
            streakStatsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            streakStatsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            streakStatsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            streakStatsView.heightAnchor.constraint(equalToConstant: 80),

            streakStatsStackView.leadingAnchor.constraint(equalTo: streakStatsView.leadingAnchor, constant: 16),
            streakStatsStackView.trailingAnchor.constraint(equalTo: streakStatsView.trailingAnchor, constant: -16),
            streakStatsStackView.topAnchor.constraint(equalTo: streakStatsView.topAnchor, constant: 16),
            streakStatsStackView.bottomAnchor.constraint(equalTo: streakStatsView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Setup Header View
    func setupHeaderView() {
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 12
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.1
        headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerView.layer.shadowRadius = 4
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        let largeFlameImageView = UIImageView(image: UIImage(systemName: "flame.fill"))
        largeFlameImageView.tintColor = .systemOrange
        largeFlameImageView.contentMode = .scaleAspectFit
        largeFlameImageView.translatesAutoresizingMaskIntoConstraints = false

        // Increase image size and make it more prominent
        largeFlameImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        largeFlameImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true

        let daysStackView = UIStackView()
        daysStackView.axis = .horizontal
        daysStackView.distribution = .equalSpacing
        daysStackView.alignment = .center
        daysStackView.spacing = 16  // Increase spacing for more separation
        daysStackView.translatesAutoresizingMaskIntoConstraints = false

        let days = ["S", "M", "T", "W", "Th", "F", "S"]
        for day in days {
            let dayContainer = UIStackView()
            dayContainer.axis = .vertical
            dayContainer.alignment = .center
            dayContainer.spacing = 8  // Increase space between the flame icon and day label
            dayContainer.translatesAutoresizingMaskIntoConstraints = false

            let flameImage = UIImageView(image: UIImage(systemName: "flame.fill"))
            flameImage.tintColor = .systemOrange
            flameImage.contentMode = .scaleAspectFit
            flameImage.translatesAutoresizingMaskIntoConstraints = false

            // Increase flame icon size
            flameImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
            flameImage.widthAnchor.constraint(equalToConstant: 24).isActive = true

            let dayLabel = UILabel()
            dayLabel.text = day
            dayLabel.font = UIFont.boldSystemFont(ofSize: 18)  // Increased font size
            dayLabel.textAlignment = .center
            dayLabel.translatesAutoresizingMaskIntoConstraints = false

            dayContainer.addArrangedSubview(flameImage)
            dayContainer.addArrangedSubview(dayLabel)
            daysStackView.addArrangedSubview(dayContainer)

            NSLayoutConstraint.activate([
                flameImage.heightAnchor.constraint(equalToConstant: 24),
                flameImage.widthAnchor.constraint(equalToConstant: 24),
            ])
        }
        headerView.addSubview(daysStackView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: streakStatsView.bottomAnchor, constant: 32),  // Increased spacing from the streakStatsView
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 100),  // Increased height of header for better spacing

            daysStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            daysStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            daysStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }


    // MARK: - Setup Calendar View
    func setupCalendarView() {
        calendarView.backgroundColor = .white
        calendarView.layer.cornerRadius = 12
        calendarView.layer.shadowColor = UIColor.black.cgColor
        calendarView.layer.shadowOpacity = 0.1
        calendarView.layer.shadowOffset = CGSize(width: 0, height: 2)
        calendarView.layer.shadowRadius = 4
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarView)

        previousMonthButton.setTitle("<", for: .normal)
        previousMonthButton.setTitleColor(.systemOrange, for: .normal)
        previousMonthButton.addTarget(self, action: #selector(handlePreviousMonth), for: .touchUpInside)
        previousMonthButton.translatesAutoresizingMaskIntoConstraints = false

        nextMonthButton.setTitle(">", for: .normal)
        nextMonthButton.setTitleColor(.systemOrange, for: .normal)
        nextMonthButton.addTarget(self, action: #selector(handleNextMonth), for: .touchUpInside)
        nextMonthButton.translatesAutoresizingMaskIntoConstraints = false

        monthYearLabel.text = formattedMonthYear()
        monthYearLabel.font = UIFont.boldSystemFont(ofSize: 22)
        monthYearLabel.textAlignment = .center
        monthYearLabel.translatesAutoresizingMaskIntoConstraints = false

        let calendarHeaderStack = UIStackView(arrangedSubviews: [previousMonthButton, monthYearLabel, nextMonthButton])
        calendarHeaderStack.axis = .horizontal
        calendarHeaderStack.alignment = .center
        calendarHeaderStack.distribution = .equalSpacing
        calendarHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        calendarView.addSubview(calendarHeaderStack)

        calendarCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.backgroundColor = .white
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.addSubview(calendarCollectionView)

        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            calendarHeaderStack.topAnchor.constraint(equalTo: calendarView.topAnchor, constant: 16),
            calendarHeaderStack.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
            calendarHeaderStack.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),

            calendarCollectionView.topAnchor.constraint(equalTo: calendarHeaderStack.bottomAnchor, constant: 16),
            calendarCollectionView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
            calendarCollectionView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
            calendarCollectionView.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -16)
        ])
    }
}
