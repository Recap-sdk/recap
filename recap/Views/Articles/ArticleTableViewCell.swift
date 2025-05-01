//
//  ArticleTableViewCell.swift
//  Recap
//
//  Created by admin70 on 05/11/24.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    static let identifier = "ArticleTableViewCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        view.layer.shadowColor = Constants.FontandColors.defaultshadowColor
        view.layer.shadowOpacity = Float(
            Constants.FontandColors.defaultshadowOpacity
        )
        view.layer.shadowOffset = Constants.FontandColors.defaultshadowOffset
        view.layer.shadowRadius = Constants.FontandColors.defaultshadowRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.FontandColors.titleFont
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.FontandColors.subtitleFont
        label.textColor = Constants.FontandColors.subtitleColor
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addSubview(articleImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate(
[
            // Using consistent padding from PaddingKeys for container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor
                .constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: Constants.paddingKeys.DefaultPaddingLeft
                ),
            containerView.trailingAnchor
                .constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: Constants.paddingKeys.DefaultPaddingRight
                ),
            containerView.bottomAnchor
                .constraint(
                    equalTo: contentView.bottomAnchor,
                    constant: Constants.paddingKeys.DefaultPaddingBottom
                ),
            
            articleImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            articleImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            articleImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            articleImageView.heightAnchor.constraint(equalToConstant: 180),

            titleLabel.topAnchor
                .constraint(
                    equalTo: articleImageView.bottomAnchor,
                    constant: Constants.paddingKeys.DefaultPaddingTop
                ),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),

            subtitleLabel.topAnchor
                .constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: Constants.paddingKeys.DefaultPaddingTop
                ),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ]
)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with article: Article) {
        articleImageView.image = article.image
        titleLabel.text = article.title
        subtitleLabel.text = String(article.content.prefix(100))
    }
}
