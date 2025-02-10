//
//  LetsReadCardView.swift
//  recap
//
//  Created by admin70 on 11/02/25.
//
import UIKit

class LetsReadCardView: UIView {
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let separatorView = UIView()
    private let arrowImageView = UIImageView()
    
    var navigateToDetail: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupTapGesture()
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        translatesAutoresizingMaskIntoConstraints = false
        
        // Icon Image
        iconImageView.image = UIImage(named: "BigShoesTorso")
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        
        // Title Label
        titleLabel.text = "Let's Read"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // Arrow Image
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .systemGray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowImageView)
        
        // Separator View
        separatorView.backgroundColor = .systemGray
        separatorView.alpha = 0.5
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        
        // Description Label
        descriptionLabel.text = "Reduces memory decline by 30%."
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .systemGray
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowImageView.leadingAnchor, constant: -8),
            
            arrowImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            arrowImageView.heightAnchor.constraint(equalToConstant: 22),
            
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            separatorView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 24),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            descriptionLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapCard() {
        navigateToDetail?()
    }
}

#Preview {
    LetsReadCardView()
}
