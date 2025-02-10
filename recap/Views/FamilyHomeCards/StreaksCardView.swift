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
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.systemOrange.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(streaksLabel)
        addSubview(arrowImageView)
        addSubview(separatorView)
        addSubview(statsStackView)

        let maxStreakView = createStatView(title: "Max Streak", value: "0")
        let currentStreakView = createStatView(title: "Current Streak", value: "0")
        let activeDaysView = createStatView(title: "Active Days", value: "0")

        statsStackView.addArrangedSubview(maxStreakView)
        statsStackView.addArrangedSubview(currentStreakView)
        statsStackView.addArrangedSubview(activeDaysView)

        NSLayoutConstraint.activate([
            streaksLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            streaksLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            // Right Arrow
            arrowImageView.centerYAnchor.constraint(equalTo: streaksLabel.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            arrowImageView.heightAnchor.constraint(equalToConstant: 22),

            separatorView.topAnchor.constraint(equalTo: streaksLabel.bottomAnchor, constant: 15),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            statsStackView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statsStackView.heightAnchor.constraint(equalToConstant: 60),
            statsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func createStatView(title: String, value: String) -> UIView {
        let statView = UIView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold) // Increased font size
        valueLabel.textColor = .systemOrange

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
