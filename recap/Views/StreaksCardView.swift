//
//  StreakStatsView.swift
//  Recap
//
//  Created by admin70 on 15/01/25.
//

import UIKit

class StreakCardView: UIView {

    var onTap: (() -> Void)?
    
    private let streaksLabel: UILabel = {
        let label = UILabel()
        label.text = "Streaks 🔥"
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
        addTapGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        addTapGesture()
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(streaksLabel)
        addSubview(arrowImageView)
        addSubview(statsStackView)

        let maxStreakView = createStatView(title: "Max Streak", value: "9")
        let currentStreakView = createStatView(title: "Current Streak", value: "5")
        let activeDaysView = createStatView(title: "Active Days", value: "18")

        statsStackView.addArrangedSubview(maxStreakView)
        statsStackView.addArrangedSubview(currentStreakView)
        statsStackView.addArrangedSubview(activeDaysView)

        NSLayoutConstraint.activate([
            // Streak Label Position
            streaksLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            streaksLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            streaksLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowImageView.leadingAnchor, constant: -8),
            
            // Right Arrow (Same size as DailyQuestionCardView)
            arrowImageView.centerYAnchor.constraint(equalTo: streaksLabel.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            arrowImageView.heightAnchor.constraint(equalToConstant: 22),

            // Stats Stack View
            statsStackView.topAnchor.constraint(equalTo: streaksLabel.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statsStackView.heightAnchor.constraint(equalToConstant: 50),
            statsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func createStatView(title: String, value: String) -> UIView {
        let statView = UIView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .gray

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = .black

        let stackView = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        statView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: statView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: statView.centerYAnchor)
        ])

        return statView
    }

    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        onTap?()
    }
}

#Preview(){
    StreakCardView()
}
