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
//    func setupStreakStatsView() {
//        streakStatsView.backgroundColor = .white
//        streakStatsView.layer.cornerRadius = 12
//        streakStatsView.layer.shadowColor = UIColor.black.cgColor
//        streakStatsView.layer.shadowOpacity = 0.1
//        streakStatsView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        streakStatsView.layer.shadowRadius = 4
//        streakStatsView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(streakStatsView)
//
//        let streakStatsStackView = UIStackView()
//        streakStatsStackView.axis = .horizontal
//        streakStatsStackView.distribution = .fillEqually
//        streakStatsStackView.alignment = .center
//        streakStatsStackView.translatesAutoresizingMaskIntoConstraints = false
//
//        let maxStreakView = createStatView(title: "Max Streak", value: "0")
//        let currentStreakView = createStatView(title: "Current Streak", value: "0")
//        let activeDaysView = createStatView(title: "Active Days", value: "0")
//
//        streakStatsStackView.addArrangedSubview(maxStreakView)
//        streakStatsStackView.addArrangedSubview(currentStreakView)
//        streakStatsStackView.addArrangedSubview(activeDaysView)
//
//        streakStatsView.addSubview(streakStatsStackView)
//
//        NSLayoutConstraint.activate([
//            streakStatsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            streakStatsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            streakStatsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            streakStatsView.heightAnchor.constraint(equalToConstant: 80),  // Decreased height
//
//            streakStatsStackView.leadingAnchor.constraint(equalTo: streakStatsView.leadingAnchor, constant: 16),
//            streakStatsStackView.trailingAnchor.constraint(equalTo: streakStatsView.trailingAnchor, constant: -16),
//            streakStatsStackView.topAnchor.constraint(equalTo: streakStatsView.topAnchor, constant: 16),
//            streakStatsStackView.bottomAnchor.constraint(equalTo: streakStatsView.bottomAnchor, constant: -16)
//        ])
//    }
    
    // Method to update the streak stats on the UI
    func updateStreakStats(maxStreak: Int, currentStreak: Int, activeDays: Int) {
        DispatchQueue.main.async {
            self.maxStreakLabel.text = "\(maxStreak)"
            self.currentStreakLabel.text = "\(currentStreak)"
            self.activeDaysLabel.text = "\(activeDays)"

            // Store values persistently
            UserDefaults.standard.set(maxStreak, forKey: "maxStreak")
            UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
            UserDefaults.standard.set(activeDays, forKey: "activeDays")
            UserDefaults.standard.synchronize()
        }
    }


    // Method to set up the streak stats view
    func setupStreakStatsView() {
        streakStatsView.backgroundColor = .white
        streakStatsView.layer.cornerRadius = 12
        streakStatsView.layer.shadowColor = UIColor.black.cgColor
        streakStatsView.layer.shadowOpacity = 0.1
        streakStatsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        streakStatsView.layer.shadowRadius = 4
        streakStatsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(streakStatsView)

        // Create the info button
        let infoButton = UIButton()
        infoButton.setTitle("?", for: .normal)
        infoButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12) // Smaller font
        infoButton.setTitleColor(.white, for: .normal)
        infoButton.backgroundColor = .systemOrange
        infoButton.layer.cornerRadius = 12  // Circular shape
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.isUserInteractionEnabled = true // Explicitly enabling user interaction
        streakStatsView.addSubview(infoButton)

        // Add a gesture recognizer for infoButton
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(infoButtonTapped))
        infoButton.addGestureRecognizer(tapGesture)

        let streakStatsStackView = UIStackView()
        streakStatsStackView.axis = .horizontal
        streakStatsStackView.distribution = .fillEqually
        streakStatsStackView.alignment = .center
        streakStatsStackView.spacing = 10
        streakStatsStackView.translatesAutoresizingMaskIntoConstraints = false

        let (maxStreakView, maxStreakLabel) = createStatView(title: "Max Streak", value: "0")
        let (currentStreakView, currentStreakLabel) = createStatView(title: "Current Streak", value: "0")
        let (activeDaysView, activeDaysLabel) = createStatView(title: "Active Days", value: "0")

        self.maxStreakLabel = maxStreakLabel
        self.currentStreakLabel = currentStreakLabel
        self.activeDaysLabel = activeDaysLabel

        streakStatsStackView.addArrangedSubview(maxStreakView)
        streakStatsStackView.addArrangedSubview(currentStreakView)
        streakStatsStackView.addArrangedSubview(activeDaysView)

        streakStatsView.addSubview(streakStatsStackView)

        NSLayoutConstraint.activate([
            streakStatsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            streakStatsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            streakStatsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            streakStatsView.heightAnchor.constraint(equalToConstant: 80),

            streakStatsStackView.leadingAnchor.constraint(equalTo: streakStatsView.leadingAnchor, constant: 16),
            streakStatsStackView.trailingAnchor.constraint(equalTo: streakStatsView.trailingAnchor, constant: -16),
            streakStatsStackView.topAnchor.constraint(equalTo: streakStatsView.topAnchor, constant: 12),
            streakStatsStackView.bottomAnchor.constraint(equalTo: streakStatsView.bottomAnchor, constant: -12),

            // Info button constraints
            infoButton.topAnchor.constraint(equalTo: streakStatsView.topAnchor, constant: 8),
            infoButton.trailingAnchor.constraint(equalTo: streakStatsView.trailingAnchor, constant: -8),
            infoButton.widthAnchor.constraint(equalToConstant: 24), // Smaller size
            infoButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    // Action for info button tap
    @objc func infoButtonTapped() {
        // Create a card view to show the descriptions
        let infoCard = UIView()
        infoCard.backgroundColor = .white
        infoCard.layer.cornerRadius = 12
        infoCard.layer.shadowColor = UIColor.black.cgColor
        infoCard.layer.shadowOpacity = 0.1
        infoCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        infoCard.layer.shadowRadius = 4
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoCard)

        // Add a label with the explanation text
        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.text = """
        - Max Streak: The longest streak you've ever achieved without a break. This includes the max days you answered questions consecutively.
        - Current Streak: The consecutive days your current streak is going on.
        - Active Days: The number of days you answered a question since you downloaded the app.
        """
        infoLabel.font = UIFont.systemFont(ofSize: 16)
        infoLabel.textColor = .black
        infoLabel.textAlignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoCard.addSubview(infoLabel)

        // Set up the info card's constraints
        NSLayoutConstraint.activate([
            infoCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoCard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            infoCard.heightAnchor.constraint(equalToConstant: 180),

            infoLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            infoLabel.centerYAnchor.constraint(equalTo: infoCard.centerYAnchor)
        ])

        // Add a tap gesture recognizer to dismiss the card when tapped
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissInfoCard))
        infoCard.addGestureRecognizer(tapGesture)
    }

    // Method to dismiss the info card
    @objc func dismissInfoCard() {
        // Remove the info card from the view
        if let infoCard = view.subviews.last(where: { $0 is UIView && $0.backgroundColor == .white }) {
            infoCard.removeFromSuperview()
        }
    }
    // Method to create a custom stat view with a title and value label
    func createStatView(title: String, value: String) -> (UIView, UILabel) {
        let statView = UIView()
        statView.translatesAutoresizingMaskIntoConstraints = false

        // Create and configure the value label (NUMBER IN MIDDLE)
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.boldSystemFont(ofSize: 28) // Large size for emphasis
        valueLabel.textColor = .orange // Number in Orange
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create and configure the title label (TEXT BELOW NUMBER)
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add the labels to the statView
        statView.addSubview(valueLabel)
        statView.addSubview(titleLabel)

        // Set up constraints for the labels
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: statView.centerXAnchor),
            valueLabel.topAnchor.constraint(equalTo: statView.topAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: statView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.bottomAnchor.constraint(equalTo: statView.bottomAnchor)
        ])

        return (statView, valueLabel)
    }




    // Method to set up the header view with the "This Week" heading and current dates
    func setupHeaderView() {
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 12
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.1
        headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerView.layer.shadowRadius = 4
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        let titleLabel = UILabel()
        titleLabel.text = "This Week's Streaks"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

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

            for day in currentWeekDates {
                let dayContainer = UIStackView()
                dayContainer.axis = .vertical
                dayContainer.alignment = .center
                dayContainer.spacing = 8  // Adjusted space for better layout
                dayContainer.translatesAutoresizingMaskIntoConstraints = false

                let flameImage = UIImageView(image: UIImage(systemName: "flame.fill"))

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

                // Date Label above the flame icon
                let dateLabel = UILabel()
                dateLabel.text = self.getShortDateFormat(from: day)  // Convert the date to just the day (e.g., "13")
                dateLabel.font = UIFont.boldSystemFont(ofSize: 18)  // Adjusted font size for date
                dateLabel.textAlignment = .center
                dateLabel.translatesAutoresizingMaskIntoConstraints = false

                // Short Weekday Label below the flame icon
                let shortWeekdayLabel = UILabel()
                shortWeekdayLabel.text = self.getShortWeekdayFormat(from: day)  // Short weekday format (e.g., "Mon")
                shortWeekdayLabel.font = UIFont.boldSystemFont(ofSize: 16)  // Adjusted font size for short weekday
                shortWeekdayLabel.textAlignment = .center
                shortWeekdayLabel.translatesAutoresizingMaskIntoConstraints = false

                // Add the date above the flame icon
                dayContainer.addArrangedSubview(dateLabel)

                // Add the flame icon in the center
                dayContainer.addArrangedSubview(flameImage)

                // Add the short weekday name below the flame icon
                dayContainer.addArrangedSubview(shortWeekdayLabel)

                daysStackView.addArrangedSubview(dayContainer)
            }

            DispatchQueue.main.async {
                self.headerView.addSubview(daysStackView)
                NSLayoutConstraint.activate([
                    self.headerView.topAnchor.constraint(equalTo: self.streakStatsView.bottomAnchor, constant: 12),
                    self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                    self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                    self.headerView.heightAnchor.constraint(equalToConstant: 140),  // Increased height to accommodate bigger container
                    
                    // Title label constraints
                    titleLabel.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 16),
                    titleLabel.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor),
                    
                    daysStackView.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: 16),
                    daysStackView.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -16),
                    daysStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                    daysStackView.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: -16)
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

    func getShortDateFormat(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"  // The format your dates are currently in
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "d"  // "d" gives you the day of the month (e.g., "12")
            return dateFormatter.string(from: date)
        }
        
        return ""  // Return an empty string if date conversion fails
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
            calendarView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
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
