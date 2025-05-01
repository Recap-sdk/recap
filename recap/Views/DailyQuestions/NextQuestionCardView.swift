//
//  NextQuestionCardView.swift
//  recap
//
//  Created by s1834 on 13/03/25.
//
//
//#Preview{
//    NextQuestionCardView()
//}
//
//import UIKit
//
//protocol NextQuestionCardViewDelegate: AnyObject {
//    func didTapNextQuestion()
//    func didTapReadArticle()
//}
//
//class NextQuestionCardView: UIView {
//
//    weak var delegate: NextQuestionCardViewDelegate?
//
//    private let logoImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(systemName: "sparkles")
//        imageView.tintColor = .white
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "What would you like to do next?"
//        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        label.textColor = .white
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let nextQuestionButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Next Question", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        button.setTitleColor(.white, for: .normal)
//        button.backgroundColor = ColorTheme.primary
//        button.layer.cornerRadius = 18
//        button.clipsToBounds = true
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    private let readArticleButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Read Article", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        button.setTitleColor(ColorTheme.textLight, for: .normal)
//        button.backgroundColor = ColorTheme.accent
//        button.layer.cornerRadius = 18
//        button.clipsToBounds = true
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupUI() {
//        // Apply gradient background directly to the view
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            AppColors.gradientStartColor.cgColor,
//            AppColors.gradientEndColor.cgColor
//        ]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        gradientLayer.cornerRadius = 24
//        gradientLayer.frame = bounds
//        layer.insertSublayer(gradientLayer, at: 0)
//
//        layer.cornerRadius = 24
//        layer.shadowColor = Constants.FontandColors.defaultshadowColor
//        layer.shadowOpacity = Float(Constants.FontandColors.defaultshadowOpacity)
//        layer.shadowOffset = Constants.FontandColors.defaultshadowOffset
//        layer.shadowRadius = CGFloat(Constants.FontandColors.defaultshadowRadius)
//        clipsToBounds = true
//
//        // Setup content stack
//        let headerStack = UIStackView(arrangedSubviews: [logoImageView, titleLabel])
//        headerStack.axis = .vertical
//        headerStack.spacing = 12
//        headerStack.alignment = .center
//        headerStack.translatesAutoresizingMaskIntoConstraints = false
//
//        let buttonsStack = UIStackView(arrangedSubviews: [nextQuestionButton, readArticleButton])
//        buttonsStack.axis = .vertical
//        buttonsStack.spacing = 20
//        buttonsStack.distribution = .fillEqually
//        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
//
//        let mainStack = UIStackView(arrangedSubviews: [headerStack, buttonsStack])
//        mainStack.axis = .vertical
//        mainStack.spacing = 28
//        mainStack.translatesAutoresizingMaskIntoConstraints = false
//
//        addSubview(mainStack)
//
//        NSLayoutConstraint.activate([
//            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 28),
//            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
//            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
//            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -28),
//            
//            nextQuestionButton.heightAnchor.constraint(equalToConstant: 56),
//            readArticleButton.heightAnchor.constraint(equalToConstant: 56),
//            
//            logoImageView.heightAnchor.constraint(equalToConstant: 60),
//            logoImageView.widthAnchor.constraint(equalToConstant: 60)
//        ])
//
//        // Button actions
//        nextQuestionButton.addTarget(self, action: #selector(didTapNextQuestion), for: .touchUpInside)
//        readArticleButton.addTarget(self, action: #selector(didTapReadArticle), for: .touchUpInside)
//
//        // Touch feedback
//        [nextQuestionButton, readArticleButton].forEach { button in
//            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
//            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
//        }
//    }
//
//
//    @objc private func buttonTouchDown(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.1) {
//            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//        }
//    }
//
//    @objc private func buttonTouchUp(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.1) {
//            sender.transform = .identity
//        }
//    }
//
//    @objc private func didTapNextQuestion() {
//        animateButtonTap(nextQuestionButton)
//        delegate?.didTapNextQuestion()
//    }
//
//    @objc private func didTapReadArticle() {
//        animateButtonTap(readArticleButton)
//        delegate?.didTapReadArticle()
//    }
//
//    private func animateButtonTap(_ button: UIButton) {
//        UIView.animate(withDuration: 0.15, animations: {
//            button.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
//        }) { _ in
//            UIView.animate(withDuration: 0.15) {
//                button.transform = .identity
//            }
//        }
//    }
//}


import UIKit

protocol NextQuestionCardViewDelegate: AnyObject {
    func didTapNextQuestion()
    func didTapReadArticle()
}

class NextQuestionCardView: UIView {
    weak var delegate: NextQuestionCardViewDelegate?

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sparkles")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Add a subtle glow effect
        imageView.layer.shadowColor = UIColor.white.cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize.zero
        imageView.layer.shadowRadius = 8
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "What would you like to do next?"
        label.font = UIFont.preferredFont(forTextStyle: .title2).withWeight(.bold) // Dynamic type support
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        // Add subtle shadow for readability
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.3
        // Accessibility
        label.isAccessibilityElement = true
        label.accessibilityLabel = "What would you like to do next?"
        return label
    }()

    private let nextQuestionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next Question", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColors.iconColor
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        button.clipsToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        // Accessibility
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Next Question"
        button.accessibilityHint = "Double tap to go to the next question"
        return button
    }()

    private let readArticleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Read Article", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColors.iconColor
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        button.clipsToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        // Accessibility
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Read Article"
        button.accessibilityHint = "Double tap to read an article"
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        animateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Apply gradient background directly to the view
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            AppColors.gradientStartColor.cgColor,
            AppColors.gradientEndColor.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 24
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)

        layer.cornerRadius = 24
        layer.shadowColor = Constants.FontandColors.defaultshadowColor
        layer.shadowOpacity = Float(Constants.FontandColors.defaultshadowOpacity)
        layer.shadowOffset = Constants.FontandColors.defaultshadowOffset
        layer.shadowRadius = CGFloat(Constants.FontandColors.defaultshadowRadius)
        clipsToBounds = false

        // Add gradient to buttons
        [nextQuestionButton, readArticleButton].forEach { button in
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor.white.withAlphaComponent(0.2).cgColor, UIColor.clear.cgColor]
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
            gradient.frame = CGRect(x: 0, y: 0, width: 300, height: 56) // Will adjust with layout
            button.layer.insertSublayer(gradient, at: 0)
        }

        // Setup content stack
        let headerStack = UIStackView(arrangedSubviews: [logoImageView, titleLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 16 // Increased spacing
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let buttonsStack = UIStackView(arrangedSubviews: [nextQuestionButton, readArticleButton])
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 24 // Increased spacing
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [headerStack, buttonsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 32 // Increased spacing
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 32), // Increased padding
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32), // Increased padding
            
            nextQuestionButton.heightAnchor.constraint(equalToConstant: 56),
            readArticleButton.heightAnchor.constraint(equalToConstant: 56),
            
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            logoImageView.widthAnchor.constraint(equalToConstant: 60)
        ])

        // Button actions
        nextQuestionButton.addTarget(self, action: #selector(didTapNextQuestion), for: .touchUpInside)
        readArticleButton.addTarget(self, action: #selector(didTapReadArticle), for: .touchUpInside)

        // Touch feedback
        [nextQuestionButton, readArticleButton].forEach { button in
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
    }

    private func animateAppearance() {
        // Fade-in animation for the card
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.alpha = 1
            self.transform = .identity
        }

        // Bounce animation for the logo
        logoImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.logoImageView.transform = .identity
        }
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }

    @objc private func didTapNextQuestion() {
        animateButtonTap(nextQuestionButton)
        delegate?.didTapNextQuestion()
    }

    @objc private func didTapReadArticle() {
        animateButtonTap(readArticleButton)
        delegate?.didTapReadArticle()
    }

    private func animateButtonTap(_ button: UIButton) {
        // Create a ripple effect
        let ripple = CAShapeLayer()
        let rippleSize: CGFloat = 60
        let ripplePath = UIBezierPath(ovalIn: CGRect(x: button.bounds.midX - rippleSize / 2, y: button.bounds.midY - rippleSize / 2, width: rippleSize, height: rippleSize))
        ripple.path = ripplePath.cgPath
        ripple.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
        ripple.opacity = 0
        button.layer.addSublayer(ripple)

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.5
        scaleAnimation.toValue = 2.0
        scaleAnimation.duration = 0.4

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = 0.4

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        animationGroup.duration = 0.4
        ripple.add(animationGroup, forKey: "ripple")

        // Scale animation for the button
        UIView.animate(withDuration: 0.15, animations: {
            button.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                button.transform = .identity
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient frame for the card
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
        }
        // Update gradient frame for buttons
        [nextQuestionButton, readArticleButton].forEach { button in
            if let gradient = button.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
                gradient.frame = button.bounds
            }
        }
    }
}

#Preview {
    NextQuestionCardView()
}

// Extension to support dynamic font weight
extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: descriptor, size: 0)
    }
}
