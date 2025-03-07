//
//  StreaksViewController+CollectionView.swift
//  recap
//
//  Created by user@47 on 16/01/25.
//

import UIKit

extension StreaksViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - UICollectionViewDataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth(year: currentYear, month: currentMonth) // Get the number of days in the current month
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }

        let day = indexPath.item + 1
        let currentDate = Date()
        let calendar = Calendar.current
        let components = DateComponents(year: currentYear, month: currentMonth, day: day)
        let cellDate = calendar.date(from: components)!

        // Convert day to formatted string for matching the streakDates keys
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: cellDate)

        // Check if the day exists in the streakDates dictionary
        if let isStreakDay = streakDates[formattedDate] {
            if isStreakDay {
                cell.contentView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.5)
            } else {
                cell.contentView.backgroundColor = .white
            }
        } else if cellDate > currentDate {
            cell.contentView.backgroundColor = .clear
        } else {
            cell.contentView.backgroundColor = .white
        }

        // Set the day label
        cell.dayLabel.text = "\(day)"
        cell.contentView.layer.cornerRadius = cell.contentView.frame.width / 2
        return cell
    }

    // MARK: - Helper Method to Get Number of Days in a Month
    func daysInMonth(year: Int, month: Int) -> Int {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month)
        return calendar.range(of: .day, in: .month, for: calendar.date(from: dateComponents)!)?.count ?? 30
    }
}
