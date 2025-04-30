//
//  GameCompletionViewController.swift.swift
//  recap
//
//  Created by Diptayan Jash on 06/03/25.
//

import Foundation
import UIKit
import Lottie

class GameCompletionViewController: UIViewController {
    // Closure to handle exit action
    var onExitTapped: (() -> Void)?

    private let animationView: LottieAnimationView = {
        guard let animation = LottieAnimation.named("gameComplete", bundle: .main) else {
            fatalError("Lottie file not found")
        }
        
        let lottieView = LottieAnimationView(animation: animation)
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .playOnce
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

    private let successLabel: UILabel = {
        let label = UILabel()
        label.text = "Well Done!"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var exitButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .large

        let button = UIButton(configuration: config)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        playLottieAnimation()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)

        view.addSubview(containerView)
        containerView.addSubview(animationView)
        containerView.addSubview(successLabel)
        containerView.addSubview(exitButton)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 350),

            animationView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 200),
            animationView.heightAnchor.constraint(equalToConstant: 200),

            successLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 10),
            successLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            exitButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            exitButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 200),
            exitButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func playLottieAnimation() {
        animationView.play()
    }

    @objc private func exitButtonTapped() {
        self.dismiss(animated: true) {
            self.onExitTapped?()
        }
    }
}
