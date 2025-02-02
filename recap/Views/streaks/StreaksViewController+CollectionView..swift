//
//  StreaksViewController+CollectionView..swift
//  recap
//
//  Created by user@47 on 16/01/25.
//

import UIKit

extension StreaksViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth() // Get the number of days in the current month
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }
        
        let day = indexPath.item + 1
        cell.dayLabel.text = "\(day)"
        cell.contentView.backgroundColor = calendarData[day] == true ? UIColor.systemOrange.withAlphaComponent(0.5) : .white
        cell.contentView.layer.cornerRadius = cell.contentView.frame.width / 2
        return cell
    }
    
    // MARK: - Helper Method to Get Number of Days in a Month
    func daysInMonth() -> Int {
        let components = DateComponents(year: currentYear, month: currentMonth)
        let date = Calendar.current.date(from: components)!
        let range = Calendar.current.range(of: .day, in: .month, for: date)!
        return range.count
    }
}
