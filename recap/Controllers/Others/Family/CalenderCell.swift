//
//  CalenderCell.swift
//  recap
//
//  Created by s1834 on 16/01/25.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    let dayLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = frame.width / 2
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.clipsToBounds = true
        
        dayLabel.font = UIFont.systemFont(ofSize: 16)
        dayLabel.textAlignment = .center
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayLabel)

        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(withDay day: String?, isSelected: Bool, isCurrentDay: Bool) {
        if let day = day {
            dayLabel.text = day
            dayLabel.textColor = .black
            contentView.backgroundColor = .white
        } else {
            dayLabel.text = ""
            contentView.backgroundColor = .clear
        }
        if isSelected {
            contentView.backgroundColor = UIColor.systemBlue
            dayLabel.textColor = .white
        } else if isCurrentDay {
            contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
            dayLabel.textColor = .black
        }
        
        if isCurrentDay {
            contentView.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            contentView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
