//
//  StreaksViewController+Helpers.swift
//  recap
//
//  Created by user@47 on 16/01/25.
//

import UIKit

extension StreaksViewController {
    func formattedYearMonth() -> String {
        let yearMonthFormatter = DateFormatter()
        yearMonthFormatter.dateFormat = "yyyy-MM"
        let date = Calendar.current.date(from: DateComponents(year: currentYear, month: currentMonth))!
        return yearMonthFormatter.string(from: date)
    }
    
    // MARK: - Format Month and Year
    func formattedMonthYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        let components = DateComponents(year: currentYear, month: currentMonth)
        let date = Calendar.current.date(from: components)!
        return dateFormatter.string(from: date)
    }

    // MARK: - Create Stat View
    func createStatView(title: String, value: String) -> UIView {
        let container = UIView()

        // Value Label
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.boldSystemFont(ofSize: 24) // Increased font size
        valueLabel.textAlignment = .center
        valueLabel.textColor = .systemOrange // Orange color for the number
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(valueLabel)

        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        // Constraints
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }
}
