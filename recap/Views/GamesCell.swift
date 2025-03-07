//
//  GamesCell.swift
//  recap
//
//  Created by Diptayan Jash on 09/11/24.
//

import UIKit

class GamesCell: UICollectionViewCell {
    static let identifier = "GameCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()

    private let accessoryIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.3)
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 15
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.backgroundColor = .white

        // Enable Auto Layout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        accessoryIcon.translatesAutoresizingMaskIntoConstraints = false
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(accessoryIcon)
        contentView.addSubview(dividerLine)
        contentView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 130), // Fixed height

            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),

            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: accessoryIcon.leadingAnchor, constant: -10),

            accessoryIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            accessoryIcon.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            accessoryIcon.widthAnchor.constraint(equalToConstant: 15),
            accessoryIcon.heightAnchor.constraint(equalToConstant: 15),

            dividerLine.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dividerLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            dividerLine.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            dividerLine.heightAnchor.constraint(equalToConstant: 1),

            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            descriptionLabel.topAnchor.constraint(equalTo: dividerLine.bottomAnchor, constant: 5)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with gamesDemo: Games) {
        imageView.image = UIImage(named: gamesDemo.imageName)
        nameLabel.text = gamesDemo.name
        descriptionLabel.text = gamesDemo.description
    }
}
