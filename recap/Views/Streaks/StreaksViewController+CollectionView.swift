

//
//  StreaksViewController+CollectionView.swift
//  recap
//
//  Created by s1834 on 16/01/25.
//

import UIKit

extension StreaksViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Total cells = days in month + leading empty cells for weekday offset, capped at 42 for a 6-row grid
        let days = daysInMonth(year: currentYear, month: currentMonth)
        let firstDayOffset = firstDayWeekdayOffset(year: currentYear, month: currentMonth)
        return min(days + firstDayOffset, 42) // Ensure no extra cells beyond a 6-row grid
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }

        let firstDayOffset = firstDayWeekdayOffset(year: currentYear, month: currentMonth)
        let dayIndex = indexPath.item - firstDayOffset + 1
        let daysInCurrentMonth = daysInMonth(year: currentYear, month: currentMonth)

        // Handle empty cells (before 1st of month or after last day)
        if indexPath.item < firstDayOffset || dayIndex > daysInCurrentMonth {
            cell.dayLabel.text = ""
            cell.contentView.backgroundColor = .clear
            cell.contentView.layer.borderWidth = 0
            cell.contentView.layer.cornerRadius = 0
            return cell
        }

        // Configure cell for valid day
        let day = dayIndex
        let calendar = Calendar.current
        let components = DateComponents(year: currentYear, month: currentMonth, day: day)
        let cellDate = calendar.date(from: components)!

        // Convert day to formatted string for matching streakDates keys
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: cellDate)

        // Check if the day exists in the streakDates dictionary
        let currentDate = Date()
        if let isStreakDay = streakDates[formattedDate] {
            if isStreakDay {
                cell.contentView.backgroundColor = AppColors.primaryButtonColor
            } else {
                cell.contentView.backgroundColor = Constants.BGs.GreyBG
            }
        } else if cellDate > currentDate {
            cell.contentView.backgroundColor = .clear
        } else {
            cell.contentView.backgroundColor = Constants.BGs.GreyBG
        }

        // Set the day label with consistent font
        cell.dayLabel.text = "\(day)"
        cell.dayLabel.font = Constants.FontandColors.descriptionFont
        cell.dayLabel.textColor = AppColors.primaryTextColor
        cell.contentView.layer.cornerRadius = cell.contentView.frame.width / 2
        cell.contentView.layer.masksToBounds = true

        return cell
    }

    // Get Number of Days in a Month
    func daysInMonth(year: Int, month: Int) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Set Sunday as the first day of the week (1 = Sunday)
        let dateComponents = DateComponents(year: year, month: month)
        return calendar.range(of: .day, in: .month, for: calendar.date(from: dateComponents)!)?.count ?? 30
    }

    // Calculate the weekday offset for the 1st of the month
    func firstDayWeekdayOffset(year: Int, month: Int) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Set Sunday as the first day of the week (1 = Sunday)
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        guard let firstDay = calendar.date(from: dateComponents) else { return 0 }
        let weekday = calendar.component(.weekday, from: firstDay)
        // Adjust weekday to 0-based index (Sunday = 0, Monday = 1, ..., Saturday = 6)
        return (weekday - 1)
    }

    // Define layout for cells (adjust size for 7-column grid)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.width - (Constants.paddingKeys.DefaultPaddingLeft * 2)
        let cellWidth = totalWidth / 7 // 7 columns for days of the week
        let cellHeight = cellWidth // Square cells
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: CGFloat(Constants.paddingKeys.DefaultPaddingTop),
            left: CGFloat(Constants.paddingKeys.DefaultPaddingLeft),
            bottom: CGFloat(Constants.paddingKeys.DefaultPaddingTop),
            right: CGFloat(Constants.paddingKeys.DefaultPaddingLeft)
        )
    }
}


