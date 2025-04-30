//
//  Untitled.swift
//  recap
//
//  Created by admin70 on 11/02/25.
//

import UIKit

class StreaksCardView: UICollectionViewCell {
    static let reuseIdentifier = "StreaksCardView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Streaks"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "See how active you are."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cosmonaut"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .systemPurple
        layer.cornerRadius = 12
        clipsToBounds = true

        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, iconImageView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9)
        ])
    }
}
#Preview {
    StreakCardView()
}
