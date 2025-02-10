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
        
        let maxStreakView = createStatView(title: "Max Streak", value: "0")
        let currentStreakView = createStatView(title: "Current Streak", value: "0")
        let activeDaysView = createStatView(title: "Active Days", value: "0")
        
        streakStatsStackView.addArrangedSubview(maxStreakView)
        streakStatsStackView.addArrangedSubview(currentStreakView)
        streakStatsStackView.addArrangedSubview(activeDaysView)
        
        streakStatsView.addSubview(streakStatsStackView)
        
        NSLayoutConstraint.activate([
            streakStatsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            streakStatsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            streakStatsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            streakStatsView.heightAnchor.constraint(equalToConstant: 80),  // Decreased height
            
            streakStatsStackView.leadingAnchor.constraint(equalTo: streakStatsView.leadingAnchor, constant: 16),
            streakStatsStackView.trailingAnchor.constraint(equalTo: streakStatsView.trailingAnchor, constant: -16),
            streakStatsStackView.topAnchor.constraint(equalTo: streakStatsView.topAnchor, constant: 16),
            streakStatsStackView.bottomAnchor.constraint(equalTo: streakStatsView.bottomAnchor, constant: -16)
        ])
    }
    
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
        daysStackView.spacing = 16  // Increased spacing for more separation
        daysStackView.translatesAutoresizingMaskIntoConstraints = false

        // Get the current year and month (yyyy-MM format)
        let currentYearMonth = getCurrentYearMonth()

        // Fetch streaks for the current year and month
        streakService.getStreaksForUser(yearMonth: currentYearMonth) { [weak self] streak in
            guard let self = self else { return }

            // Update the streak dates UI
            if let streak = streak {
                self.updateStreakDatesWithStreaks(streak.streakDates)
            } else {
                print("⚠️ No streak data found for \(currentYearMonth), but not uploading default data.")
            }

            // Ensure the calendar reloads
            DispatchQueue.main.async {
                self.calendarCollectionView.reloadData()
            }
        }

        // Get the current week (Sunday to Saturday)
        let currentWeekDates = getCurrentWeekDates()

        // Fetch streakDates dynamically from StreakService
        streakService.getStreaksForUser(yearMonth: currentYearMonth) { [weak self] streak in
            guard let self = self else { return }

            // Assuming `streakDates` is a dictionary of dates and their corresponding streak status
            var streakDates: [String: Bool] = [:]

            if let streak = streak {
                streakDates = streak.streakDates  // Example data for streak dates
            }

            print("Current Week Dates: \(currentWeekDates)")  // Debug statement to check the current week dates
            print("Streak Dates: \(streakDates)")  // Debug statement to check the streak dates

            for day in currentWeekDates {
                let dayContainer = UIStackView()
                dayContainer.axis = .vertical
                dayContainer.alignment = .center
                dayContainer.spacing = 8  // Increase space between the flame icon and day label
                dayContainer.translatesAutoresizingMaskIntoConstraints = false

                let flameImage = UIImageView(image: UIImage(systemName: "flame.fill"))

                // Debugging date format comparison
                print("Comparing day: \(day) with streakDates: \(streakDates)")

                // Check if the date exists in streakDates dictionary and its value is true
                if let isStreak = streakDates[day], isStreak {
                    flameImage.tintColor = UIColor.systemOrange  // Orange color if it's a streak day
                } else {
                    flameImage.tintColor = .systemGray  // Default gray for unmarked days
                }

                flameImage.contentMode = .scaleAspectFit
                flameImage.translatesAutoresizingMaskIntoConstraints = false

                // Increase flame icon size
                flameImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
                flameImage.widthAnchor.constraint(equalToConstant: 24).isActive = true

                let dayLabel = UILabel()
                dayLabel.text = self.getShortWeekdayFormat(from: day)  // Convert the date to the short weekday format
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
            
            DispatchQueue.main.async {
                self.headerView.addSubview(daysStackView)
                NSLayoutConstraint.activate([
                    self.headerView.topAnchor.constraint(equalTo: self.streakStatsView.bottomAnchor, constant: 32),  // Increased spacing from the streakStatsView
                    self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                    self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                    self.headerView.heightAnchor.constraint(equalToConstant: 70),  // Decreased height

                    daysStackView.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 16),
                    daysStackView.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -16),
                    daysStackView.centerYAnchor.constraint(equalTo: self.headerView.centerYAnchor)
                ])
            }
        }
    }

    // Helper function to get the current year's month (yyyy-MM format)
    func getCurrentYearMonth() -> String {
        let calendar = Calendar.current
        let currentDate = Date()
        let yearMonthFormatter = DateFormatter()
        yearMonthFormatter.dateFormat = "yyyy-MM"
        
        return yearMonthFormatter.string(from: currentDate)
    }

    // Helper function to get the current week's dates (Sunday to Saturday)
    func getCurrentWeekDates() -> [String] {
        let calendar = Calendar.current
        var currentWeekDays = [String]()
        
        // Get today's date
        let today = Date()
        
        // Get the current weekday index (1 = Sunday, 7 = Saturday)
        let weekdayIndex = calendar.component(.weekday, from: today)
        
        // Calculate the date for Sunday (start of the week)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekdayIndex - 1), to: today)!
        
        // Add the 7 days starting from Sunday
        for i in 0..<7 {
            if let dayOfWeek = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "yyyy-MM-dd"  // Full date format
                let dayString = dayFormatter.string(from: dayOfWeek)
                currentWeekDays.append(dayString)
            }
        }
        
        return currentWeekDays
    }

    // Helper function to get the short weekday format (e.g., "Mon", "Tue")
    func getShortWeekdayFormat(from date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Convert the input date string into a Date object
        if let dateObj = dateFormatter.date(from: date) {
            // Now convert the Date object into the short weekday format
            dateFormatter.dateFormat = "E"  // Short weekday format (e.g., "Mon", "Tue")
            return dateFormatter.string(from: dateObj)
        }
        return ""
    }


    // MARK: - Setup Calendar View
    func setupCalendarView() {
        // Calendar View setup
        calendarView.backgroundColor = .white
        calendarView.layer.cornerRadius = 12
        calendarView.layer.shadowColor = UIColor.black.cgColor
        calendarView.layer.shadowOpacity = 0.1
        calendarView.layer.shadowOffset = CGSize(width: 0, height: 2)
        calendarView.layer.shadowRadius = 4
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarView)
        
        // Previous Month Button setup
        previousMonthButton.setTitle("<", for: .normal)
        previousMonthButton.setTitleColor(.systemOrange, for: .normal)
        previousMonthButton.addTarget(self, action: #selector(handlePreviousMonth), for: .touchUpInside)
        previousMonthButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Next Month Button setup
        nextMonthButton.setTitle(">", for: .normal)
        nextMonthButton.setTitleColor(.systemOrange, for: .normal)
        nextMonthButton.addTarget(self, action: #selector(handleNextMonth), for: .touchUpInside)
        nextMonthButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Month-Year Label setup
        monthYearLabel.text = formattedMonthYear()
        monthYearLabel.font = UIFont.boldSystemFont(ofSize: 22)
        monthYearLabel.textAlignment = .center
        monthYearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Calendar Header Stack setup
        let calendarHeaderStack = UIStackView(arrangedSubviews: [previousMonthButton, monthYearLabel, nextMonthButton])
        calendarHeaderStack.axis = .horizontal
        calendarHeaderStack.alignment = .center
        calendarHeaderStack.distribution = .equalSpacing
        calendarHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        calendarView.addSubview(calendarHeaderStack)
        
        // Calendar Collection View setup
        calendarCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.backgroundColor = .white
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.addSubview(calendarCollectionView)
        
        // Constraints for the calendar view and its subviews
        NSLayoutConstraint.activate([
            // Calendar View constraints
            calendarView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarView.heightAnchor.constraint(equalToConstant: 370),  // Decreased height
            
            // Calendar Header Stack constraints
            calendarHeaderStack.topAnchor.constraint(equalTo: calendarView.topAnchor, constant: 16),
            calendarHeaderStack.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
            calendarHeaderStack.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
            
            // Calendar Collection View constraints
            calendarCollectionView.topAnchor.constraint(equalTo: calendarHeaderStack.bottomAnchor, constant: 16),
            calendarCollectionView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
            calendarCollectionView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
            calendarCollectionView.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -16)
        ])
    }
}
