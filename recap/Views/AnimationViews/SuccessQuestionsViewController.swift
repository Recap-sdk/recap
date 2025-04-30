//
//  SuccessQuestionsViewController.swift
//  recap
//
//  Created by Diptayan Jash on 05/03/25.
//

import Lottie
import UIKit

class SuccessQuestionsViewController: UIViewController {
    // Closure to handle exit action
    var onExitTapped: (() -> Void)?

    private let animationView: LottieAnimationView = {
        guard let animation = LottieAnimation.named("SuccessAnimation", bundle: .main) else {
            fatalError("Lottie file not found")
        }

        let lottieView = LottieAnimationView(animation: animation)
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        return lottieView
    }()

    // Confetti Emitter Layer
    private lazy var confettiLayer: CAEmitterLayer = {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        emitterLayer.emitterShape = .line
        emitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)

        // Create confetti cells
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemYellow,
            .systemPurple, .systemOrange, .systemPink,
        ]

        let cells = colors.map { color -> CAEmitterCell in
            let cell = CAEmitterCell()
            cell.birthRate = 10
            cell.lifetime = 10
            cell.velocity = CGFloat.random(in: 100 ... 300)
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.spinRange = 5
            cell.scale = 0.1
            cell.scaleRange = 0.2
            cell.color = color.cgColor

            // Create a confetti-like shape
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 10, height: 10), false, 0)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(color.cgColor)
            context?.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
            context?.rotate(by: .pi / 4)
            context?.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            cell.contents = image?.cgImage
            return cell
        }

        emitterLayer.emitterCells = cells
        return emitterLayer
    }()

    // UI Components
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = Constants.FontandColors.defaultshadowColor
        view.layer.shadowOffset = Constants.FontandColors.defaultshadowOffset
        view.layer.shadowRadius = Constants.FontandColors.defaultshadowRadius
        view.layer.shadowOpacity = Float(
            Constants.FontandColors.defaultshadowOpacity
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let successTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Congratulations!"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let successDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "You've completed all your questions for now.\nKeep up the great work!"
        label.font = Constants.FontandColors.descriptionFont
        label.textColor = Constants.FontandColors.descriptionColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var exitButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = UIColor.systemOrange
        configuration.cornerStyle = .large

        let button = UIButton(configuration: configuration)
        button.setTitle("Continue to Home", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        playLottieAnimation()
    }

    private func playLottieAnimation() {
        animationView.play()
    }

    private func setupViews() {
        // Setup background
        view.backgroundColor = .clear
        view.layer.addSublayer(confettiLayer)

        // Add views
        view.addSubview(backgroundView)
        backgroundView.addSubview(containerView)
        containerView.addSubview(animationView)
        containerView.addSubview(successTitleLabel)
        containerView.addSubview(successDescriptionLabel)
        containerView.addSubview(exitButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            containerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            containerView.heightAnchor.constraint(equalToConstant: 450),

            animationView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 200),
            animationView.heightAnchor.constraint(equalToConstant: 200),

            successTitleLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 20),
            successTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            successTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            successDescriptionLabel.topAnchor.constraint(equalTo: successTitleLabel.bottomAnchor, constant: 10),
            successDescriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            successDescriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            exitButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
            exitButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 200),
            exitButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func animateSuccessView() {
        // Confetti animation
        confettiLayer.birthRate = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.confettiLayer.birthRate = 10
        }

        // Container animation
        containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        containerView.alpha = 0

        // Spring animation for container
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }

        // Fade out confetti after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 1) {
                self.confettiLayer.birthRate = 0
            }
        }
    }

    @objc private func exitButtonTapped() {
        // Animate out with confetti
        UIView.animate(withDuration: 0.5, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.containerView.alpha = 0
            self.confettiLayer.birthRate = 0
        }) { _ in
            self.dismiss(animated: false) {
                self.onExitTapped?()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        confettiLayer.removeFromSuperlayer()
    }
}
