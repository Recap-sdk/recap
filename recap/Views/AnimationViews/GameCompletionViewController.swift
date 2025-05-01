//
//  GameCompletionViewController.swift
//  recap
//
//  Created by Diptayan Jash on 06/03/25.
//

import UIKit
import Lottie

class GameCompletionViewController: UIViewController {
    // Completion details
    var secondsElapsed: Int = 0
    var moves: Int = 0
    var score: Int = 0 // Added score property

    // Closures for actions
    var onPlayAgainTapped: (() -> Void)?
    var onExitTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?

    private let animationView: LottieAnimationView = {
        guard let animation = LottieAnimation.named("gameComplete", bundle: .main) else {
            fatalError("Lottie file not found")
        }
        
        let lottieView = LottieAnimationView(animation: animation)
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        return lottieView
    }()

    // UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let confettiView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "confetti"))
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let successLabel: UILabel = {
        let label = UILabel()
        label.text = "Congratulations!"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .systemIndigo
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let completionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let timeIconLabel: UILabel = {
        let label = UILabel()
        label.text = "⏱️"
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let movesIconLabel: UILabel = {
        let label = UILabel()
        label.text = "🔄"
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let movesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scoreIconLabel: UILabel = {
        let label = UILabel()
        label.text = "🏆"
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var playAgainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play Again", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.backgroundColor = Constants.ButtonStyle.DefaultButtonBackgroundColor
        button.setTitleColor(.systemGreen, for: .normal)
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(playAgainTapped), for: .touchUpInside)
        return button
    }()

    private lazy var exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Exit", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.backgroundColor = Constants.ButtonStyle.DefaultButtonBackgroundColor
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = Constants.ButtonStyle.DefaultButtonBackgroundColor
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStarRating()
        updateStats()
        
        // Add a subtle pulsing effect to the success label
        animateSuccessLabel()
        
        // Accessibility announcement
        UIAccessibility.post(notification: .announcement, argument: "Congratulations! You completed the game!")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playLottieAnimation()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)

        view.addSubview(containerView)
        containerView.addSubview(confettiView)
        containerView.addSubview(animationView)
        containerView.addSubview(successLabel)
        containerView.addSubview(starStackView)
        containerView.addSubview(completionDescriptionLabel)
        containerView.addSubview(statsContainerView)
        containerView.addSubview(buttonsStackView)
        containerView.addSubview(shareButton)
        
        // Add stats elements to stats container
        statsContainerView.addSubview(timeIconLabel)
        statsContainerView.addSubview(timeLabel)
        statsContainerView.addSubview(movesIconLabel)
        statsContainerView.addSubview(movesLabel)
        statsContainerView.addSubview(scoreIconLabel)
        statsContainerView.addSubview(scoreLabel)
        
        // Add buttons to stack view
        buttonsStackView.addArrangedSubview(playAgainButton)
        buttonsStackView.addArrangedSubview(exitButton)

        NSLayoutConstraint.activate(
[
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor
                .constraint(
                    equalTo: view.leadingAnchor,
                    constant: Constants.paddingKeys.DefaultPaddingLeft
                        ),
            containerView.trailingAnchor
                .constraint(
                    equalTo: view.trailingAnchor,
                    constant: Constants.paddingKeys.DefaultPaddingRight
                ),
            containerView.widthAnchor.constraint(equalToConstant: 340),
            containerView.heightAnchor.constraint(equalToConstant: 480),
            
            confettiView.topAnchor.constraint(equalTo: containerView.topAnchor),
            confettiView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            confettiView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            confettiView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            animationView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 150),
            animationView.heightAnchor.constraint(equalToConstant: 150),

            successLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 5),
            successLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            starStackView.topAnchor.constraint(equalTo: successLabel.bottomAnchor, constant: 10),
            starStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            starStackView.heightAnchor.constraint(equalToConstant: 30),

            completionDescriptionLabel.topAnchor.constraint(equalTo: starStackView.bottomAnchor, constant: 10),
            completionDescriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            completionDescriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            statsContainerView.topAnchor.constraint(equalTo: completionDescriptionLabel.bottomAnchor, constant: 15),
            statsContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            statsContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            statsContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Time stats
            timeIconLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 20),
            timeIconLabel.centerYAnchor.constraint(equalTo: statsContainerView.centerYAnchor),
            
            timeLabel.leadingAnchor.constraint(equalTo: timeIconLabel.trailingAnchor, constant: 8),
            timeLabel.centerYAnchor.constraint(equalTo: timeIconLabel.centerYAnchor),
            
            // Moves stats
            movesIconLabel.centerXAnchor.constraint(equalTo: statsContainerView.centerXAnchor),
            movesIconLabel.centerYAnchor.constraint(equalTo: statsContainerView.centerYAnchor),
            
            movesLabel.leadingAnchor.constraint(equalTo: movesIconLabel.trailingAnchor, constant: 8),
            movesLabel.centerYAnchor.constraint(equalTo: movesIconLabel.centerYAnchor),
            
            // Score stats
            scoreIconLabel.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -60),
            scoreIconLabel.centerYAnchor.constraint(equalTo: statsContainerView.centerYAnchor),
            
            scoreLabel.leadingAnchor.constraint(equalTo: scoreIconLabel.trailingAnchor, constant: 8),
            scoreLabel.centerYAnchor.constraint(equalTo: scoreIconLabel.centerYAnchor),

            buttonsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25),
            buttonsStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buttonsStackView.widthAnchor.constraint(equalToConstant: 280),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.ButtonStyle.DefaultButtonHeight),
            
            // Share button
            shareButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            shareButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            shareButton.widthAnchor.constraint(equalToConstant: 40),
            shareButton.heightAnchor.constraint(equalToConstant: 40)
        ]
)
    }
    
    private func setupStarRating() {
        // Calculate star rating based on moves and time
        let starCount = calculateStarRating()
        
        // Clear any existing stars
        starStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add stars based on rating
        for i in 1...3 {
            let imageView = UIImageView()
            if i <= starCount {
                imageView.image = UIImage(systemName: "star.fill")
                imageView.tintColor = .systemYellow
            } else {
                imageView.image = UIImage(systemName: "star")
                imageView.tintColor = .systemGray3
            }
            imageView.contentMode = .scaleAspectFit
            starStackView.addArrangedSubview(imageView)
            
            // Add a bounce animation for the stars
            imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.5, delay: Double(i) * 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                imageView.transform = .identity
            })
        }
    }
    
    private func calculateStarRating() -> Int {
        // This is just an example - adjust the logic based on your game mechanics
        if moves < 10 && secondsElapsed < 30 {
            return 3
        } else if moves < 20 && secondsElapsed < 60 {
            return 2
        } else {
            return 1
        }
    }
    
    private func updateStats() {
        // Format time
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        timeLabel.text = String(format: "%d:%02d", minutes, seconds)
        
        // Set moves
        movesLabel.text = "\(moves)"
        
        // Calculate score - adjust formula as needed
        score = max(100 - (moves * 1) - (secondsElapsed / 5), 0)
        scoreLabel.text = "\(score)"
        
        // Update description
        completionDescriptionLabel.text = "You've mastered the challenge!"
    }
    
    private func animateSuccessLabel() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.1, 1.0]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        successLabel.layer.add(animation, forKey: "pulse")
    }

    private func playLottieAnimation() {
        animationView.play { [weak self] _ in
            // Add a subtle bounce to the container when animation completes
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                self?.containerView.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self?.containerView.transform = .identity
                }
            }
        }
    }

    @objc private func playAgainTapped() {
        // Add a tactile feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Scale animation
        UIView.animate(withDuration: 0.1, animations: {
            self.playAgainButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.playAgainButton.transform = CGAffineTransform.identity
            }) { _ in
                self.dismiss(animated: true) {
                    self.onPlayAgainTapped?()
                }
            }
        }
    }

    @objc private func exitTapped() {
        // Add a tactile feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Scale animation
        UIView.animate(withDuration: 0.1, animations: {
            self.exitButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.exitButton.transform = CGAffineTransform.identity
            }) { _ in
                self.dismiss(animated: true) {
                    self.onExitTapped?()
                }
            }
        }
    }
    
    @objc private func shareTapped() {
        // Add a tactile feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Create a screenshot to share
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, 0.0)
        containerView.drawHierarchy(in: containerView.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Items to share
        let items: [Any] = [
            "I just completed the game with a score of \(score)! 🎮",
            screenshot as Any
        ].compactMap { $0 }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = shareButton
        present(activityVC, animated: true)
        
        onShareTapped?()
    }
}
